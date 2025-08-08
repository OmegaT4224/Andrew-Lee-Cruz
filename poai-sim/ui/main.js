/**
 * VIOLET-AF PoAI Simulator Frontend
 * 
 * Interactive dashboard for simulating and testing PoAI devices and computations
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */

class PoAISimulator {
    constructor() {
        this.ws = null;
        this.devices = {};
        this.submissions = [];
        this.isConnected = false;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.connectWebSocket();
        this.loadInitialData();
    }

    setupEventListeners() {
        // Refresh button
        document.getElementById('refreshBtn').addEventListener('click', () => {
            this.loadInitialData();
        });

        // PoAI submission
        document.getElementById('submitPoAI').addEventListener('click', () => {
            this.submitPoAI();
        });

        // Clear log
        document.getElementById('clearLog').addEventListener('click', () => {
            document.getElementById('activityLog').innerHTML = '';
        });

        // Modal close
        document.getElementById('closeModal').addEventListener('click', () => {
            document.getElementById('deviceModal').style.display = 'none';
        });

        // Close modal when clicking outside
        window.addEventListener('click', (event) => {
            const modal = document.getElementById('deviceModal');
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        });
    }

    connectWebSocket() {
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = `${protocol}//${window.location.host}/ws`;
        
        this.ws = new WebSocket(wsUrl);
        
        this.ws.onopen = () => {
            this.isConnected = true;
            this.updateConnectionStatus('Connected');
            this.log('WebSocket connected', 'success');
        };

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleWebSocketMessage(data);
        };

        this.ws.onclose = () => {
            this.isConnected = false;
            this.updateConnectionStatus('Disconnected');
            this.log('WebSocket disconnected', 'error');
            
            // Attempt to reconnect after 5 seconds
            setTimeout(() => {
                this.log('Attempting to reconnect...', 'info');
                this.connectWebSocket();
            }, 5000);
        };

        this.ws.onerror = (error) => {
            this.log(`WebSocket error: ${error.message || 'Unknown error'}`, 'error');
        };
    }

    handleWebSocketMessage(data) {
        switch (data.type) {
            case 'initial_data':
                this.devices = {};
                data.devices.forEach(device => {
                    this.devices[device.device_id] = device;
                });
                this.submissions = data.submissions || [];
                this.updateUI();
                break;

            case 'device_update':
                this.devices[data.device_id] = data.device;
                this.updateDeviceCard(data.device_id);
                this.log(`Device ${data.device_id} updated`, 'info');
                break;

            case 'poai_submission':
                this.submissions.unshift(data.submission);
                if (this.submissions.length > 20) {
                    this.submissions = this.submissions.slice(0, 20);
                }
                this.updateSubmissionsList();
                this.updateStatusCards();
                this.log(`PoAI submission from ${data.device_id}: ${data.submission.digest.substring(0, 16)}...`, 'success');
                break;

            case 'energy_policy_change':
                this.log(`Energy policy change for ${data.device_id}: ${data.energy_compliant ? 'COMPLIANT' : 'NON-COMPLIANT'}`, 'warning');
                break;

            case 'pong':
                // Handle ping/pong for connection keep-alive
                break;

            default:
                console.log('Unknown message type:', data.type);
        }
    }

    async loadInitialData() {
        try {
            const [devicesResponse, submissionsResponse, statusResponse] = await Promise.all([
                fetch('/api/devices'),
                fetch('/api/poai/submissions'),
                fetch('/api/status')
            ]);

            const devicesData = await devicesResponse.json();
            const submissionsData = await submissionsResponse.json();
            const statusData = await statusResponse.json();

            // Update devices
            this.devices = {};
            devicesData.devices.forEach(device => {
                this.devices[device.device_id] = device;
            });

            // Update submissions
            this.submissions = submissionsData.submissions || [];

            this.updateUI();
            this.log('Initial data loaded', 'info');
        } catch (error) {
            this.log(`Failed to load initial data: ${error.message}`, 'error');
        }
    }

    updateUI() {
        this.updateStatusCards();
        this.updateDevicesGrid();
        this.updateSubmissionsList();
        this.updateDeviceSelect();
    }

    updateConnectionStatus(status) {
        const indicator = document.getElementById('connectionIndicator');
        const text = document.getElementById('connectionText');
        
        indicator.className = `status-indicator ${this.isConnected ? 'online' : 'offline'}`;
        text.textContent = status;
    }

    updateStatusCards() {
        const devices = Object.values(this.devices);
        
        document.getElementById('totalDevices').textContent = devices.length;
        document.getElementById('onlineDevices').textContent = devices.filter(d => d.is_online).length;
        document.getElementById('energyCompliant').textContent = devices.filter(d => d.energy_compliant).length;
        document.getElementById('totalSubmissions').textContent = this.submissions.length;
    }

    updateDevicesGrid() {
        const grid = document.getElementById('devicesGrid');
        grid.innerHTML = '';

        Object.values(this.devices).forEach(device => {
            const card = this.createDeviceCard(device);
            grid.appendChild(card);
        });
    }

    createDeviceCard(device) {
        const card = document.createElement('div');
        card.className = 'device-card';
        card.dataset.deviceId = device.device_id;

        const statusClass = device.is_online ? 'online' : 'offline';
        const energyClass = device.energy_compliant ? 'compliant' : 'non-compliant';

        card.innerHTML = `
            <div class="device-header">
                <h3>${device.name}</h3>
                <div class="device-status ${statusClass}">
                    ${device.is_online ? 'Online' : 'Offline'}
                </div>
            </div>
            <div class="device-id">${device.device_id}</div>
            
            <div class="device-metrics">
                <div class="metric">
                    <span class="label">Battery:</span>
                    <span class="value">
                        ${device.battery_level}%
                        ${device.is_charging ? '⚡' : '🔋'}
                    </span>
                </div>
                <div class="metric">
                    <span class="label">CPU Temp:</span>
                    <span class="value">${device.cpu_temperature.toFixed(1)}°C</span>
                </div>
                <div class="metric">
                    <span class="label">Screen:</span>
                    <span class="value">${device.screen_on ? 'On' : 'Off'}</span>
                </div>
            </div>

            <div class="energy-policy ${energyClass}">
                <span class="energy-indicator"></span>
                Energy Policy: ${device.energy_compliant ? 'Compliant' : 'Non-compliant'}
            </div>

            <div class="device-stats">
                <div class="stat">
                    <span class="label">Total Submissions:</span>
                    <span class="value">${device.total_submissions}</span>
                </div>
                <div class="stat">
                    <span class="label">Last Submission:</span>
                    <span class="value">${this.formatTime(device.last_poai_submission)}</span>
                </div>
            </div>

            <div class="device-controls">
                <div class="control-group">
                    <label>Battery Level:</label>
                    <input type="range" min="0" max="100" value="${device.battery_level}" 
                           class="range-input" data-control="battery_level">
                    <span class="range-value">${device.battery_level}%</span>
                </div>
                
                <div class="control-group">
                    <label>CPU Temperature:</label>
                    <input type="range" min="25" max="60" step="0.1" value="${device.cpu_temperature}" 
                           class="range-input" data-control="cpu_temperature">
                    <span class="range-value">${device.cpu_temperature.toFixed(1)}°C</span>
                </div>

                <div class="control-group checkbox-group">
                    <label>
                        <input type="checkbox" ${device.is_charging ? 'checked' : ''} 
                               data-control="is_charging">
                        Charging
                    </label>
                    <label>
                        <input type="checkbox" ${device.screen_on ? 'checked' : ''} 
                               data-control="screen_on">
                        Screen On
                    </label>
                </div>

                <button class="btn btn-primary btn-small" onclick="poaiSim.showDeviceDetails('${device.device_id}')">
                    View Details
                </button>
            </div>
        `;

        // Add event listeners for controls
        this.setupDeviceControls(card, device.device_id);

        return card;
    }

    setupDeviceControls(card, deviceId) {
        const controls = card.querySelectorAll('[data-control]');
        
        controls.forEach(control => {
            const controlType = control.dataset.control;
            
            if (control.type === 'range') {
                control.addEventListener('input', (e) => {
                    const value = parseFloat(e.target.value);
                    const valueSpan = e.target.nextElementSibling;
                    
                    if (controlType === 'battery_level') {
                        valueSpan.textContent = `${value}%`;
                    } else if (controlType === 'cpu_temperature') {
                        valueSpan.textContent = `${value.toFixed(1)}°C`;
                    }
                    
                    this.updateDevice(deviceId, controlType, value);
                });
            } else if (control.type === 'checkbox') {
                control.addEventListener('change', (e) => {
                    this.updateDevice(deviceId, controlType, e.target.checked);
                });
            }
        });
    }

    async updateDevice(deviceId, parameter, value) {
        try {
            const updateData = {};
            updateData[parameter] = value;

            const response = await fetch(`/api/devices/${deviceId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(updateData)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            // Device will be updated via WebSocket message
        } catch (error) {
            this.log(`Failed to update device ${deviceId}: ${error.message}`, 'error');
        }
    }

    updateDeviceCard(deviceId) {
        const device = this.devices[deviceId];
        if (!device) return;

        const existingCard = document.querySelector(`[data-device-id="${deviceId}"]`);
        if (existingCard) {
            const newCard = this.createDeviceCard(device);
            existingCard.replaceWith(newCard);
        }

        this.updateStatusCards();
    }

    updateSubmissionsList() {
        const list = document.getElementById('submissionsList');
        list.innerHTML = '';

        this.submissions.slice(0, 10).forEach(submission => {
            const item = document.createElement('div');
            item.className = 'submission-item';
            
            item.innerHTML = `
                <div class="submission-header">
                    <span class="device-id">${submission.device_id}</span>
                    <span class="timestamp">${this.formatTime(submission.timestamp)}</span>
                </div>
                <div class="submission-digest">
                    <code>${submission.digest}</code>
                </div>
                <div class="submission-meta">
                    <span class="energy-status ${submission.energy_compliant ? 'compliant' : 'non-compliant'}">
                        ${submission.energy_compliant ? '✅ Energy Compliant' : '❌ Non-compliant'}
                    </span>
                </div>
            `;
            
            list.appendChild(item);
        });
    }

    updateDeviceSelect() {
        const select = document.getElementById('deviceSelect');
        const currentValue = select.value;
        
        select.innerHTML = '<option value="">Select a device...</option>';
        
        Object.values(this.devices).forEach(device => {
            const option = document.createElement('option');
            option.value = device.device_id;
            option.textContent = `${device.name} (${device.device_id})`;
            option.disabled = !device.is_online;
            select.appendChild(option);
        });

        // Restore selection if still valid
        if (currentValue && this.devices[currentValue]) {
            select.value = currentValue;
        }
    }

    async submitPoAI() {
        const deviceId = document.getElementById('deviceSelect').value;
        const inputData = document.getElementById('inputData').value;
        const forceComputation = document.getElementById('forceComputation').checked;

        if (!deviceId) {
            this.log('Please select a device', 'error');
            return;
        }

        if (!inputData.trim()) {
            this.log('Please enter input data', 'error');
            return;
        }

        try {
            const response = await fetch('/api/poai/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    device_id: deviceId,
                    input_data: inputData,
                    force_computation: forceComputation
                })
            });

            const result = await response.json();

            if (response.ok) {
                this.log(`PoAI submission successful: ${result.submission.digest.substring(0, 16)}...`, 'success');
            } else {
                this.log(`PoAI submission failed: ${result.detail}`, 'error');
            }
        } catch (error) {
            this.log(`PoAI submission error: ${error.message}`, 'error');
        }
    }

    async showDeviceDetails(deviceId) {
        try {
            const response = await fetch(`/api/devices/${deviceId}`);
            const data = await response.json();

            const device = data.device;
            const energyPolicy = data.energy_policy;

            const modal = document.getElementById('deviceModal');
            const modalName = document.getElementById('modalDeviceName');
            const modalBody = document.getElementById('modalBody');

            modalName.textContent = device.name;
            modalBody.innerHTML = `
                <div class="device-details">
                    <h4>Device Information</h4>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <label>Device ID:</label>
                            <value><code>${device.device_id}</code></value>
                        </div>
                        <div class="detail-item">
                            <label>Status:</label>
                            <value class="${device.is_online ? 'online' : 'offline'}">
                                ${device.is_online ? 'Online' : 'Offline'}
                            </value>
                        </div>
                        <div class="detail-item">
                            <label>Location:</label>
                            <value>${device.location}</value>
                        </div>
                        <div class="detail-item">
                            <label>Attestation Valid:</label>
                            <value class="${device.attestation_valid ? 'valid' : 'invalid'}">
                                ${device.attestation_valid ? 'Valid' : 'Invalid'}
                            </value>
                        </div>
                    </div>

                    <h4>Energy Policy Status</h4>
                    <div class="policy-grid">
                        <div class="policy-item ${energyPolicy.battery_ok ? 'pass' : 'fail'}">
                            <span class="policy-check">${energyPolicy.battery_ok ? '✅' : '❌'}</span>
                            <span>Battery: ${device.battery_level}% ${device.is_charging ? '(Charging)' : ''}</span>
                        </div>
                        <div class="policy-item ${energyPolicy.temperature_ok ? 'pass' : 'fail'}">
                            <span class="policy-check">${energyPolicy.temperature_ok ? '✅' : '❌'}</span>
                            <span>CPU Temperature: ${device.cpu_temperature.toFixed(1)}°C</span>
                        </div>
                        <div class="policy-item ${energyPolicy.screen_ok ? 'pass' : 'fail'}">
                            <span class="policy-check">${energyPolicy.screen_ok ? '✅' : '❌'}</span>
                            <span>Screen: ${device.screen_on ? 'On' : 'Off'}</span>
                        </div>
                        <div class="policy-item ${energyPolicy.online_ok ? 'pass' : 'fail'}">
                            <span class="policy-check">${energyPolicy.online_ok ? '✅' : '❌'}</span>
                            <span>Online Status: ${device.is_online ? 'Online' : 'Offline'}</span>
                        </div>
                    </div>

                    <div class="policy-summary ${energyPolicy.meets_requirements ? 'compliant' : 'non-compliant'}">
                        <strong>
                            Overall Status: ${energyPolicy.meets_requirements ? 'ENERGY POLICY COMPLIANT' : 'ENERGY POLICY NON-COMPLIANT'}
                        </strong>
                    </div>

                    <h4>Statistics</h4>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <label>Total Submissions:</label>
                            <value>${device.total_submissions.toLocaleString()}</value>
                        </div>
                        <div class="stat-item">
                            <label>Last Submission:</label>
                            <value>${this.formatTime(device.last_poai_submission)}</value>
                        </div>
                    </div>
                </div>
            `;

            modal.style.display = 'block';
        } catch (error) {
            this.log(`Failed to load device details: ${error.message}`, 'error');
        }
    }

    log(message, type = 'info') {
        const logContainer = document.getElementById('activityLog');
        const logEntry = document.createElement('div');
        logEntry.className = `log-entry log-${type}`;
        
        const timestamp = new Date().toLocaleTimeString();
        logEntry.innerHTML = `
            <span class="log-timestamp">[${timestamp}]</span>
            <span class="log-message">${message}</span>
        `;
        
        logContainer.appendChild(logEntry);
        
        // Auto-scroll if enabled
        if (document.getElementById('autoScroll').checked) {
            logContainer.scrollTop = logContainer.scrollHeight;
        }

        // Limit log entries to 100
        while (logContainer.children.length > 100) {
            logContainer.removeChild(logContainer.firstChild);
        }
    }

    formatTime(timestamp) {
        return new Date(timestamp * 1000).toLocaleTimeString();
    }
}

// Initialize the simulator when DOM is loaded
let poaiSim;
document.addEventListener('DOMContentLoaded', () => {
    poaiSim = new PoAISimulator();
});

// Keep WebSocket connection alive
setInterval(() => {
    if (poaiSim && poaiSim.ws && poaiSim.ws.readyState === WebSocket.OPEN) {
        poaiSim.ws.send(JSON.stringify({ type: 'ping' }));
    }
}, 30000);