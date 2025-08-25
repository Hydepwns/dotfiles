/**
 * Dotfiles Framework Dashboard - Interactive JavaScript
 */

class DotfilesDashboard {
    constructor() {
        this.apiEndpoint = '/api';
        this.refreshInterval = 30000; // 30 seconds
        this.charts = {};
        this.init();
    }

    async init() {
        this.setupEventListeners();
        this.setupTabs();
        this.initializeCharts();
        await this.loadInitialData();
        this.startAutoRefresh();
        this.updateTimestamp();
    }

    setupEventListeners() {
        // Header actions
        document.getElementById('refresh-btn').addEventListener('click', () => {
            this.refreshData();
        });

        // Test controls
        const runTestsBtn = document.getElementById('run-tests');
        if (runTestsBtn) {
            runTestsBtn.addEventListener('click', () => {
                this.runTests();
            });
        }

        const runCoverageBtn = document.getElementById('run-coverage');
        if (runCoverageBtn) {
            runCoverageBtn.addEventListener('click', () => {
                this.runCoverage();
            });
        }

        const qualityCheckBtn = document.getElementById('quality-check');
        if (qualityCheckBtn) {
            qualityCheckBtn.addEventListener('click', () => {
                this.runQualityCheck();
            });
        }

        // Plugin controls
        const createPluginBtn = document.getElementById('create-plugin');
        if (createPluginBtn) {
            createPluginBtn.addEventListener('click', () => {
                this.createPlugin();
            });
        }

        const refreshPluginsBtn = document.getElementById('refresh-plugins');
        if (refreshPluginsBtn) {
            refreshPluginsBtn.addEventListener('click', () => {
                this.refreshPlugins();
            });
        }

        // Log controls
        const clearLogsBtn = document.getElementById('clear-logs');
        if (clearLogsBtn) {
            clearLogsBtn.addEventListener('click', () => {
                this.clearLogs();
            });
        }

        const exportLogsBtn = document.getElementById('export-logs');
        if (exportLogsBtn) {
            exportLogsBtn.addEventListener('click', () => {
                this.exportLogs();
            });
        }
    }

    setupTabs() {
        const navItems = document.querySelectorAll('.nav-item');
        const tabContents = document.querySelectorAll('.tab-content');

        navItems.forEach(item => {
            item.addEventListener('click', () => {
                const tabId = item.dataset.tab;
                
                // Remove active class from all nav items and tab contents
                navItems.forEach(nav => nav.classList.remove('active'));
                tabContents.forEach(tab => tab.classList.remove('active'));
                
                // Add active class to clicked nav item and corresponding tab
                item.classList.add('active');
                document.getElementById(`${tabId}-tab`).classList.add('active');
                
                // Load tab-specific data
                this.loadTabData(tabId);
            });
        });
    }

    initializeCharts() {
        // Performance Chart
        const performanceCtx = document.getElementById('performance-chart');
        if (performanceCtx) {
            this.charts.performance = new Chart(performanceCtx, {
                type: 'line',
                data: {
                    labels: this.generateTimeLabels(12),
                    datasets: [{
                        label: 'Execution Time (ms)',
                        data: this.generateSampleData(12, 50, 200),
                        borderColor: '#2563eb',
                        backgroundColor: 'rgba(37, 99, 235, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: '#e2e8f0'
                            }
                        },
                        x: {
                            grid: {
                                color: '#e2e8f0'
                            }
                        }
                    }
                }
            });
        }

        // Test Results Chart
        const testCtx = document.getElementById('test-chart');
        if (testCtx) {
            this.charts.test = new Chart(testCtx, {
                type: 'bar',
                data: {
                    labels: ['Unit Tests', 'Integration', 'Quality Check', 'Coverage'],
                    datasets: [{
                        label: 'Success Rate (%)',
                        data: [95, 88, 92, 85],
                        backgroundColor: [
                            '#10b981',
                            '#3b82f6',
                            '#f59e0b',
                            '#8b5cf6'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100,
                            grid: {
                                color: '#e2e8f0'
                            }
                        },
                        x: {
                            grid: {
                                color: '#e2e8f0'
                            }
                        }
                    }
                }
            });
        }
    }

    async loadInitialData() {
        await Promise.all([
            this.loadSystemInfo(),
            this.loadTestResults(),
            this.loadPlugins()
        ]);
    }

    async loadTabData(tabId) {
        switch (tabId) {
            case 'system':
                await this.loadSystemInfo();
                break;
            case 'testing':
                await this.loadTestResults();
                break;
            case 'plugins':
                await this.loadPlugins();
                break;
            case 'logs':
                await this.loadLogs();
                break;
        }
    }

    async loadSystemInfo() {
        try {
            // Simulate API call for system info
            const systemInfo = await this.simulateApiCall('/api/system', {
                os: 'Linux 6.12.41',
                memory: { used: 65, total: 100 },
                disk: { used: 45, total: 100 },
                cpu: { usage: 25 }
            });

            this.updateSystemDisplay(systemInfo);
        } catch (error) {
            console.error('Failed to load system info:', error);
        }
    }

    updateSystemDisplay(systemInfo) {
        const osInfo = document.getElementById('os-info');
        if (osInfo) osInfo.textContent = systemInfo.os;

        const memoryProgress = document.getElementById('memory-progress');
        const memoryInfo = document.getElementById('memory-info');
        if (memoryProgress && memoryInfo) {
            memoryProgress.style.width = `${systemInfo.memory.used}%`;
            memoryInfo.textContent = `${systemInfo.memory.used}% of ${systemInfo.memory.total}GB`;
        }

        const diskProgress = document.getElementById('disk-progress');
        const diskInfo = document.getElementById('disk-info');
        if (diskProgress && diskInfo) {
            diskProgress.style.width = `${systemInfo.disk.used}%`;
            diskInfo.textContent = `${systemInfo.disk.used}% used`;
        }

        const cpuProgress = document.getElementById('cpu-progress');
        const cpuInfo = document.getElementById('cpu-info');
        if (cpuProgress && cpuInfo) {
            cpuProgress.style.width = `${systemInfo.cpu.usage}%`;
            cpuInfo.textContent = `${systemInfo.cpu.usage}% usage`;
        }
    }

    async loadTestResults() {
        try {
            const testResults = await this.simulateApiCall('/api/tests', {
                passed: 47,
                failed: 2,
                coverage: 85
            });

            this.updateTestDisplay(testResults);
        } catch (error) {
            console.error('Failed to load test results:', error);
        }
    }

    updateTestDisplay(testResults) {
        const passedEl = document.getElementById('tests-passed');
        const failedEl = document.getElementById('tests-failed');
        const coverageEl = document.getElementById('coverage-percent');

        if (passedEl) passedEl.textContent = testResults.passed;
        if (failedEl) failedEl.textContent = testResults.failed;
        if (coverageEl) coverageEl.textContent = `${testResults.coverage}%`;
    }

    async loadPlugins() {
        try {
            const plugins = await this.simulateApiCall('/api/plugins', [
                {
                    name: 'Example Plugin',
                    description: 'A sample plugin demonstrating the framework',
                    version: 'v1.0.0',
                    status: 'active'
                }
            ]);

            this.updatePluginsList(plugins);
        } catch (error) {
            console.error('Failed to load plugins:', error);
        }
    }

    updatePluginsList(plugins) {
        const pluginList = document.getElementById('plugin-list');
        if (!pluginList) return;

        pluginList.innerHTML = plugins.map(plugin => `
            <div class="plugin-item">
                <div class="plugin-info">
                    <h4>${plugin.name}</h4>
                    <p>${plugin.description}</p>
                    <div class="plugin-meta">
                        <span class="plugin-version">${plugin.version}</span>
                        <span class="plugin-status ${plugin.status}">${plugin.status}</span>
                    </div>
                </div>
                <div class="plugin-actions">
                    <button class="btn btn-small btn-secondary">Configure</button>
                    <button class="btn btn-small btn-danger">Disable</button>
                </div>
            </div>
        `).join('');
    }

    async loadLogs() {
        // Simulate loading logs
        const logViewer = document.getElementById('log-viewer');
        if (!logViewer) return;

        const sampleLogs = [
            { time: '2024-01-15 10:30:45', level: 'INFO', message: 'Dashboard initialized successfully' },
            { time: '2024-01-15 10:29:32', level: 'INFO', message: 'Cache warmed up with 23 entries' },
            { time: '2024-01-15 10:28:15', level: 'WARNING', message: 'Plugin update available: example-plugin' },
            { time: '2024-01-15 10:27:03', level: 'INFO', message: 'Test suite completed: 47 passed, 2 failed' }
        ];

        logViewer.innerHTML = sampleLogs.map(log => `
            <div class="log-entry">
                <span class="log-time">${log.time}</span>
                <span class="log-level ${log.level.toLowerCase()}">${log.level}</span>
                <span class="log-message">${log.message}</span>
            </div>
        `).join('');
    }

    async runTests() {
        this.showLoading('Running tests...');
        
        try {
            // Simulate test execution
            await this.delay(3000);
            
            const results = await this.simulateApiCall('/api/tests/run', {
                passed: 49,
                failed: 0,
                coverage: 87
            });
            
            this.updateTestDisplay(results);
            this.addActivity('Test suite completed successfully', 'success');
        } catch (error) {
            this.addActivity('Test execution failed', 'error');
        } finally {
            this.hideLoading();
        }
    }

    async runCoverage() {
        this.showLoading('Analyzing coverage...');
        
        try {
            await this.delay(2000);
            this.addActivity('Coverage analysis completed: 87%', 'info');
        } finally {
            this.hideLoading();
        }
    }

    async runQualityCheck() {
        this.showLoading('Running quality check...');
        
        try {
            await this.delay(2500);
            this.addActivity('Quality check passed with 0 issues', 'success');
        } finally {
            this.hideLoading();
        }
    }

    async createPlugin() {
        const pluginName = prompt('Enter plugin name:');
        if (pluginName) {
            this.showLoading('Creating plugin...');
            
            try {
                await this.delay(1500);
                this.addActivity(`Plugin '${pluginName}' created successfully`, 'success');
                await this.loadPlugins();
            } finally {
                this.hideLoading();
            }
        }
    }

    async refreshPlugins() {
        this.showLoading('Refreshing plugins...');
        try {
            await this.loadPlugins();
            this.addActivity('Plugin list refreshed', 'info');
        } finally {
            this.hideLoading();
        }
    }

    clearLogs() {
        const logViewer = document.getElementById('log-viewer');
        if (logViewer) {
            logViewer.innerHTML = '<div class="log-entry"><span class="log-message">Logs cleared</span></div>';
        }
    }

    exportLogs() {
        // Simulate log export
        const logData = "Sample log data...";
        const blob = new Blob([logData], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = `dotfiles-logs-${new Date().toISOString().slice(0, 10)}.txt`;
        a.click();
        
        URL.revokeObjectURL(url);
        this.addActivity('Logs exported successfully', 'success');
    }

    addActivity(message, type = 'info') {
        const activityList = document.getElementById('activity-list');
        if (!activityList) return;

        const iconMap = {
            success: '✓',
            info: 'ℹ',
            warning: '⚠',
            error: '✗'
        };

        const activityItem = document.createElement('div');
        activityItem.className = 'activity-item';
        activityItem.innerHTML = `
            <div class="activity-icon ${type}">${iconMap[type] || 'ℹ'}</div>
            <div class="activity-content">
                <div class="activity-title">${message}</div>
                <div class="activity-time">Just now</div>
            </div>
        `;

        activityList.insertBefore(activityItem, activityList.firstChild);
        
        // Keep only the last 10 activities
        while (activityList.children.length > 10) {
            activityList.removeChild(activityList.lastChild);
        }
    }

    showLoading(message = 'Processing...') {
        const overlay = document.getElementById('loading-overlay');
        const text = document.querySelector('.loading-text');
        
        if (overlay) {
            overlay.classList.remove('hidden');
            if (text) text.textContent = message;
        }
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay');
        if (overlay) overlay.classList.add('hidden');
    }

    async refreshData() {
        this.showLoading('Refreshing data...');
        
        try {
            await this.loadInitialData();
            this.updateTimestamp();
            this.addActivity('Dashboard data refreshed', 'info');
        } finally {
            this.hideLoading();
        }
    }

    startAutoRefresh() {
        setInterval(() => {
            this.refreshData();
        }, this.refreshInterval);
    }

    updateTimestamp() {
        const lastUpdated = document.getElementById('last-updated');
        if (lastUpdated) {
            lastUpdated.textContent = new Date().toLocaleString();
        }
    }

    // Utility functions
    generateTimeLabels(count) {
        const labels = [];
        const now = new Date();
        
        for (let i = count - 1; i >= 0; i--) {
            const time = new Date(now.getTime() - i * 5 * 60 * 1000);
            labels.push(time.toLocaleTimeString('en-US', { 
                hour: '2-digit', 
                minute: '2-digit' 
            }));
        }
        
        return labels;
    }

    generateSampleData(count, min, max) {
        return Array.from({ length: count }, () => 
            Math.floor(Math.random() * (max - min + 1)) + min
        );
    }

    async simulateApiCall(endpoint, mockData) {
        // Simulate network delay
        await this.delay(200 + Math.random() * 300);
        
        // In a real implementation, this would be:
        // const response = await fetch(endpoint);
        // return response.json();
        
        return mockData;
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new DotfilesDashboard();
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DotfilesDashboard;
}