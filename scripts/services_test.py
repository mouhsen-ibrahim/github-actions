import unittest
from unittest.mock import patch, mock_open, MagicMock, call
import os
import tempfile
import shutil
import yaml
import requests
from services import (
    Service, detect_services, is_sub_path, changed_service,
    get_services_by_kind, get_triggers, get_services_by_selector,
    get_changed_services, compare_services, current_commit,
    pick_first_success_run, list_runs, get_last_green_commit,
    run_git, GITHUB_API
)


class TestService(unittest.TestCase):

    def setUp(self):
        """Set up test fixtures before each test method."""
        self.temp_dir = tempfile.mkdtemp()
        self.service_path = os.path.join(self.temp_dir, "test_service")
        os.makedirs(self.service_path)

        self.buildfile_data = {
            'name': 'test_service',
            'kind': 'python',
            'team': 'backend',
            'version': '1.0.0'
        }

        buildfile_path = os.path.join(self.service_path, "Buildfile.yaml")
        with open(buildfile_path, 'w') as f:
            yaml.dump(self.buildfile_data, f)

    def tearDown(self):
        """Clean up after each test method."""
        shutil.rmtree(self.temp_dir)

    def test_service_init(self):
        """Test Service initialization and data loading."""
        service = Service(self.service_path)

        self.assertEqual(service.path, self.service_path)
        self.assertEqual(service.data['name'], 'test_service')
        self.assertEqual(service.data['kind'], 'python')
        self.assertEqual(service.data['team'], 'backend')
        self.assertEqual(service.data['path'], self.service_path)

    def test_service_repr(self):
        """Test Service string representation."""
        service = Service(self.service_path)
        repr_str = repr(service)
        self.assertIn('test_service', repr_str)
        self.assertIn('python', repr_str)

    def test_service_equality(self):
        """Test Service equality comparison."""
        service1 = Service(self.service_path)
        service2 = Service(self.service_path)

        # Different service path
        other_path = os.path.join(self.temp_dir, "other_service")
        os.makedirs(other_path)
        buildfile_path = os.path.join(other_path, "Buildfile.yaml")
        with open(buildfile_path, 'w') as f:
            yaml.dump(self.buildfile_data, f)
        service3 = Service(other_path)

        self.assertEqual(service1, service2)
        self.assertNotEqual(service1, service3)
        self.assertNotEqual(service1, "not_a_service")

    def test_service_hash(self):
        """Test Service hash function."""
        service1 = Service(self.service_path)
        service2 = Service(self.service_path)

        self.assertEqual(hash(service1), hash(service2))

        # Test that services can be used in sets
        service_set = {service1, service2}
        self.assertEqual(len(service_set), 1)


class TestRunGit(unittest.TestCase):

    @patch('subprocess.check_output')
    def test_run_git_success(self, mock_check_output):
        """Test successful git command execution."""
        mock_check_output.return_value = b'commit_hash\n'

        result = run_git('rev-parse', 'HEAD')

        self.assertEqual(result, 'commit_hash')
        mock_check_output.assert_called_once_with(
            ['git', 'rev-parse', 'HEAD'],
            cwd=None,
            stderr=unittest.mock.ANY
        )

    @patch('subprocess.check_output')
    def test_run_git_with_cwd(self, mock_check_output):
        """Test git command execution with custom working directory."""
        mock_check_output.return_value = b'output\n'

        run_git('status', cwd='/custom/path')

        mock_check_output.assert_called_once_with(
            ['git', 'status'],
            cwd='/custom/path',
            stderr=unittest.mock.ANY
        )

    @patch('subprocess.check_output')
    def test_run_git_failure(self, mock_check_output):
        """Test git command failure handling."""
        from subprocess import CalledProcessError
        error = CalledProcessError(1, 'git', b'error message')
        mock_check_output.side_effect = error

        with self.assertRaises(RuntimeError) as context:
            run_git('invalid-command')

        self.assertIn('git invalid-command failed', str(context.exception))
        self.assertIn('error message', str(context.exception))


class TestDetectServices(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)

    def tearDown(self):
        os.chdir(self.original_cwd)
        shutil.rmtree(self.temp_dir)

    def create_service(self, path, data):
        """Helper method to create a service directory with Buildfile.yaml."""
        full_path = os.path.join(self.temp_dir, path)
        os.makedirs(full_path, exist_ok=True)
        buildfile_path = os.path.join(full_path, "Buildfile.yaml")
        with open(buildfile_path, 'w') as f:
            yaml.dump(data, f)
        return full_path

    def test_detect_services_empty_directory(self):
        """Test detecting services in empty directory."""
        services = detect_services()
        self.assertEqual(len(services), 0)

    def test_detect_services_single_service(self):
        """Test detecting a single service."""
        service_data = {'name': 'service1', 'kind': 'python'}
        self.create_service('service1', service_data)

        services = detect_services()

        self.assertEqual(len(services), 1)
        self.assertEqual(services[0].data['name'], 'service1')

    def test_detect_services_multiple_services(self):
        """Test detecting multiple services."""
        self.create_service('service1', {'name': 'service1', 'kind': 'python'})
        self.create_service('service2', {'name': 'service2', 'kind': 'go'})
        self.create_service('nested/service3', {'name': 'service3', 'kind': 'node'})

        services = detect_services()

        self.assertEqual(len(services), 3)
        service_names = [s.data['name'] for s in services]
        self.assertIn('service1', service_names)
        self.assertIn('service2', service_names)
        self.assertIn('service3', service_names)


class TestUtilityFunctions(unittest.TestCase):

    def test_is_sub_path_true_cases(self):
        """Test is_sub_path function for true cases."""
        self.assertTrue(is_sub_path('services/serviceA', 'services/serviceA/main.go'))
        self.assertTrue(is_sub_path('./services/serviceA', 'services/serviceA/config.yaml'))
        self.assertTrue(is_sub_path('src', 'src/module/file.py'))

    def test_is_sub_path_false_cases(self):
        """Test is_sub_path function for false cases."""
        self.assertFalse(is_sub_path('services/serviceA', 'services/serviceB/main.go'))
        self.assertFalse(is_sub_path('src/module', 'src/other/file.py'))

    def test_changed_service_true(self):
        """Test changed_service function returns True when service is affected."""
        changes = ['services/serviceA/main.go', 'services/serviceB/config.yaml']

        self.assertTrue(changed_service('services/serviceA', changes))
        self.assertTrue(changed_service('services/serviceB', changes))

    def test_changed_service_false(self):
        """Test changed_service function returns False when service is not affected."""
        changes = ['services/serviceA/main.go', 'docs/README.md']

        self.assertFalse(changed_service('services/serviceC', changes))

    def test_get_services_by_kind(self):
        """Test filtering services by kind."""
        services = [
            MagicMock(data={'name': 'service1', 'kind': 'python'}),
            MagicMock(data={'name': 'service2', 'kind': 'go'}),
            MagicMock(data={'name': 'service3', 'kind': 'python'}),
        ]

        python_services = get_services_by_kind(services, 'python')
        go_services = get_services_by_kind(services, 'go')

        self.assertEqual(len(python_services), 2)
        self.assertEqual(len(go_services), 1)
        self.assertEqual(python_services[0].data['name'], 'service1')
        self.assertEqual(go_services[0].data['name'], 'service2')

    def test_get_triggers(self):
        """Test extracting triggers from config."""
        config = {
            'files': ['file1.py', 'file2.go'],
            'other_key': 'value'
        }

        triggers = get_triggers(config)

        self.assertEqual(triggers, ['file1.py', 'file2.go'])

    def test_get_triggers_empty(self):
        """Test extracting triggers when files key is missing."""
        config = {'other_key': 'value'}

        triggers = get_triggers(config)

        self.assertEqual(triggers, [])

    def test_get_services_by_selector_all(self):
        """Test selecting all services with 'all' selector."""
        services = [MagicMock(), MagicMock(), MagicMock()]
        selector = {'all': True}

        selected = get_services_by_selector(selector, services)

        self.assertEqual(len(selected), 3)
        self.assertEqual(selected, services)

    def test_get_services_by_selector_attributes(self):
        """Test selecting services by attributes."""
        services = [
            MagicMock(data={'team': 'backend', 'kind': 'python'}),
            MagicMock(data={'team': 'frontend', 'kind': 'node'}),
            MagicMock(data={'team': 'backend', 'kind': 'go'}),
        ]
        selector = {
            'attributes': {
                'team': 'backend'
            }
        }

        selected = get_services_by_selector(selector, services)

        self.assertEqual(len(selected), 2)
        self.assertEqual(selected[0].data['team'], 'backend')
        self.assertEqual(selected[1].data['team'], 'backend')


class TestGetChangedServices(unittest.TestCase):

    @patch('services.detect_services')
    def test_get_changed_services_basic(self, mock_detect_services):
        """Test basic changed services detection."""
        mock_services = [
            MagicMock(path='services/serviceA', data={'name': 'serviceA'}),
            MagicMock(path='services/serviceB', data={'name': 'serviceB'}),
        ]
        mock_detect_services.return_value = mock_services

        changes = ['services/serviceA/main.go']
        config = {'additional_services': []}

        with patch('services.changed_service') as mock_changed:
            mock_changed.side_effect = lambda path, changes: path == 'services/serviceA'

            result = get_changed_services(changes, config)

            self.assertEqual(len(result), 1)
            self.assertEqual(result[0].data['name'], 'serviceA')

    @patch('services.detect_services')
    @patch('services.get_services_by_selector')
    def test_get_changed_services_with_additional(self, mock_get_by_selector, mock_detect_services):
        """Test changed services with additional services triggered."""
        mock_services = [
            MagicMock(path='services/serviceA', data={'name': 'serviceA'}),
            MagicMock(path='services/serviceB', data={'name': 'serviceB'}),
        ]
        mock_detect_services.return_value = mock_services
        mock_get_by_selector.return_value = [mock_services[1]]  # serviceB

        changes = ['go.Dockerfile']
        config = {
            'additional_services': [
                {
                    'trigger': {'files': ['go.Dockerfile']},
                    'selector': {'attributes': {'kind': 'go'}}
                }
            ]
        }

        with patch('services.changed_service', return_value=False):
            result = get_changed_services(changes, config)

            self.assertEqual(len(result), 1)
            self.assertEqual(result[0].data['name'], 'serviceB')

    @patch('services.detect_services')
    def test_get_changed_services_deduplication(self, mock_detect_services):
        """Test that duplicate services are removed while preserving order."""
        mock_service = MagicMock(path='services/serviceA', data={'name': 'serviceA'})
        mock_detect_services.return_value = [mock_service]

        changes = ['services/serviceA/main.go']
        config = {
            'additional_services': [
                {
                    'trigger': {'files': ['services/serviceA/main.go']},
                    'selector': {'all': True}
                }
            ]
        }

        with patch('services.changed_service', return_value=True):
            with patch('services.get_services_by_selector', return_value=[mock_service]):
                result = get_changed_services(changes, config)

                # Should only have one instance despite being in both lists
                self.assertEqual(len(result), 1)


class TestCompareServices(unittest.TestCase):

    @patch('services.run_git')
    @patch('services.get_changed_services')
    def test_compare_services(self, mock_get_changed, mock_run_git):
        """Test comparing services between commits."""
        mock_run_git.return_value = 'file1.py\nfile2.go'
        mock_service = MagicMock(data={'name': 'test_service'})
        mock_get_changed.return_value = [mock_service]

        config = {'additional_services': []}
        result = compare_services('HEAD~1', config)

        mock_run_git.assert_called_once_with('diff', '--name-only', 'HEAD~1')
        mock_get_changed.assert_called_once_with(['file1.py', 'file2.go'], config)
        self.assertEqual(result, [mock_service])


class TestCurrentCommit(unittest.TestCase):

    @patch('services.run_git')
    def test_current_commit(self, mock_run_git):
        """Test getting current commit hash."""
        mock_run_git.return_value = 'abc123def456'

        result = current_commit()

        mock_run_git.assert_called_once_with('rev-parse', 'HEAD')
        self.assertEqual(result, 'abc123def456')


class TestPickFirstSuccessRun(unittest.TestCase):

    def test_pick_first_success_run_found(self):
        """Test finding the first successful run."""
        runs = [
            {'status': 'completed', 'conclusion': 'failure'},
            {'status': 'completed', 'conclusion': 'success', 'head_sha': 'abc123'},
            {'status': 'completed', 'conclusion': 'success', 'head_sha': 'def456'},
        ]

        result = pick_first_success_run(runs)

        self.assertIsNotNone(result)
        self.assertEqual(result['head_sha'], 'abc123')

    def test_pick_first_success_run_not_found(self):
        """Test when no successful run is found."""
        runs = [
            {'status': 'completed', 'conclusion': 'failure'},
            {'status': 'in_progress', 'conclusion': None},
        ]

        result = pick_first_success_run(runs)

        self.assertIsNone(result)

    def test_pick_first_success_run_empty_list(self):
        """Test with empty runs list."""
        result = pick_first_success_run([])
        self.assertIsNone(result)


class TestListRuns(unittest.TestCase):

    @patch('requests.get')
    def test_list_runs_with_workflow_id(self, mock_get):
        """Test listing runs for a specific workflow ID."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'workflow_runs': [
                {'id': 1, 'status': 'completed'},
                {'id': 2, 'status': 'completed'},
            ]
        }
        mock_get.return_value = mock_response

        runs = list_runs('owner', 'repo', 'main', 'token', workflow_id=12345)

        self.assertEqual(len(runs), 2)
        mock_get.assert_called_once()
        args, kwargs = mock_get.call_args
        self.assertIn('workflows/12345/runs', args[0])
        self.assertEqual(kwargs['params']['branch'], 'main')

    @patch('requests.get')
    def test_list_runs_with_workflow_ref(self, mock_get):
        """Test listing runs for a specific workflow file reference."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'workflow_runs': []}
        mock_get.return_value = mock_response

        list_runs('owner', 'repo', 'main', 'token', workflow_ref='ci.yml')

        args, kwargs = mock_get.call_args
        self.assertIn('workflows/ci.yml/runs', args[0])

    @patch('requests.get')
    def test_list_runs_all_workflows(self, mock_get):
        """Test listing runs for all workflows."""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'workflow_runs': []}
        mock_get.return_value = mock_response

        list_runs('owner', 'repo', 'main', 'token')

        args, kwargs = mock_get.call_args
        self.assertIn('actions/runs', args[0])
        self.assertNotIn('workflows', args[0])

    @patch('requests.get')
    def test_list_runs_api_error(self, mock_get):
        """Test handling GitHub API errors."""
        mock_response = MagicMock()
        mock_response.status_code = 404
        mock_response.text = 'Not Found'
        mock_get.return_value = mock_response

        with self.assertRaises(RuntimeError) as context:
            list_runs('owner', 'repo', 'main', 'token')

        self.assertIn('GitHub API error 404', str(context.exception))


class TestGetLastGreenCommit(unittest.TestCase):

    @patch('services.list_runs')
    @patch('services.pick_first_success_run')
    @patch('services.current_commit')
    def test_get_last_green_commit_found(self, mock_current, mock_pick, mock_list):
        """Test getting last green commit when a successful run is found."""
        mock_list.return_value = [{'id': 1}]
        mock_pick.return_value = {'head_sha': 'green_commit_123'}

        result = get_last_green_commit('owner', 'repo', 'main', 'token')

        self.assertEqual(result, 'green_commit_123')
        mock_current.assert_not_called()

    @patch('services.list_runs')
    @patch('services.pick_first_success_run')
    @patch('services.current_commit')
    def test_get_last_green_commit_not_found(self, mock_current, mock_pick, mock_list):
        """Test fallback to current commit when no successful run is found."""
        mock_list.return_value = [{'id': 1}]
        mock_pick.return_value = None
        mock_current.return_value = 'current_commit_456'

        result = get_last_green_commit('owner', 'repo', 'main', 'token')

        self.assertEqual(result, 'current_commit_456')
        mock_current.assert_called_once()

    @patch('services.list_runs')
    def test_get_last_green_commit_with_workflow(self, mock_list):
        """Test getting last green commit with specific workflow."""
        mock_list.return_value = []

        get_last_green_commit('owner', 'repo', 'main', 'token', workflow='ci.yml')

        mock_list.assert_called_once_with(
            'owner', 'repo', 'main', 'token',
            workflow_id=None, workflow_ref='ci.yml'
        )


if __name__ == '__main__':
    unittest.main()
