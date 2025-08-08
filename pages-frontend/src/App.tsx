import React, { useState, useEffect } from 'react';
import { 
  Activity, 
  Cpu, 
  Database, 
  Zap, 
  Shield, 
  Clock, 
  Users, 
  BarChart3,
  Wifi,
  Battery,
  Thermometer,
  CheckCircle,
  AlertCircle,
  RefreshCw
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';

/**
 * VIOLET-AF PoAI Dashboard
 * 
 * Real-time monitoring interface for the Proof-of-AI blockchain ecosystem
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */

interface ChainStatus {
  chainHead: {
    height: number;
    hash: string;
    timestamp: number;
    poaiDigest: string;
  };
  recentDigests: Array<{
    digest: string;
    height: number;
    timestamp: number;
  }>;
  pendingSubmissions: number;
  network: {
    name: string;
    version: string;
    creator: string;
  };
  timestamp: number;
}

interface DeviceStatus {
  deviceId: string;
  isOnline: boolean;
  batteryLevel: number;
  isCharging: boolean;
  cpuTemperature: number;
  energyCompliant: boolean;
  lastSubmission: number;
  totalSubmissions: number;
}

const MOCK_DEVICES: DeviceStatus[] = [
  {
    deviceId: 'SM-G998B_VIOLET_001',
    isOnline: true,
    batteryLevel: 85,
    isCharging: true,
    cpuTemperature: 38.5,
    energyCompliant: true,
    lastSubmission: Date.now() - 120000, // 2 minutes ago
    totalSubmissions: 142
  },
  {
    deviceId: 'iPhone14_POAI_002',
    isOnline: true,
    batteryLevel: 72,
    isCharging: false,
    cpuTemperature: 42.1,
    energyCompliant: true,
    lastSubmission: Date.now() - 300000, // 5 minutes ago
    totalSubmissions: 89
  },
  {
    deviceId: 'Pixel7_QUANTUM_003',
    isOnline: false,
    batteryLevel: 45,
    isCharging: false,
    cpuTemperature: 35.0,
    energyCompliant: false,
    lastSubmission: Date.now() - 1800000, // 30 minutes ago
    totalSubmissions: 67
  }
];

function App() {
  const [chainStatus, setChainStatus] = useState<ChainStatus | null>(null);
  const [devices, setDevices] = useState<DeviceStatus[]>(MOCK_DEVICES);
  const [isLoading, setIsLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(Date.now());
  const [wsConnected, setWsConnected] = useState(false);

  // Mock data for charts
  const [blockHeightData, setBlockHeightData] = useState([
    { time: '10:00', height: 1240, submissions: 12 },
    { time: '10:15', height: 1245, submissions: 15 },
    { time: '10:30', height: 1251, submissions: 18 },
    { time: '10:45', height: 1256, submissions: 14 },
    { time: '11:00', height: 1262, submissions: 21 },
    { time: '11:15', height: 1268, submissions: 16 },
  ]);

  const workerBaseUrl = import.meta.env.VITE_WORKER_BASE_URL || 'https://violet-af-poai-chain.yourdomain.workers.dev';

  useEffect(() => {
    fetchChainStatus();
    const interval = setInterval(fetchChainStatus, 30000); // Update every 30 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchChainStatus = async () => {
    try {
      setIsLoading(true);
      const response = await fetch(`${workerBaseUrl}/poai/status`);
      if (response.ok) {
        const status = await response.json();
        setChainStatus(status);
        setWsConnected(true);
      }
    } catch (error) {
      console.error('Failed to fetch chain status:', error);
      setWsConnected(false);
      // Use mock data for development
      setChainStatus({
        chainHead: {
          height: 1268,
          hash: '0x742d35c7f7aae7e5b2b52a2e3c4f5d9a8b7c1e0f3a2b4c5d6e7f8g9h0i1j2k3l',
          timestamp: Date.now() - 180000,
          poaiDigest: 'violet_af_quantum_digest_1268_∞'
        },
        recentDigests: [
          { digest: 'quantum_state_|0⟩+|1⟩_1268', height: 1268, timestamp: Date.now() - 180000 },
          { digest: 'entangled_pair_φ+_1267', height: 1267, timestamp: Date.now() - 360000 },
          { digest: 'superposition_ψ_1266', height: 1266, timestamp: Date.now() - 540000 }
        ],
        pendingSubmissions: 7,
        network: {
          name: 'VIOLET-AF PoAI Chain',
          version: '1.0.0',
          creator: 'ALC-ROOT-1010-1111-XCOV∞'
        },
        timestamp: Date.now()
      });
    } finally {
      setIsLoading(false);
      setLastUpdate(Date.now());
    }
  };

  const formatTime = (timestamp: number) => {
    return new Date(timestamp).toLocaleTimeString();
  };

  const formatHash = (hash: string) => {
    return `${hash.slice(0, 8)}...${hash.slice(-8)}`;
  };

  const getEnergyStatus = (device: DeviceStatus) => {
    if (device.energyCompliant) {
      return <span className="energy-indicator energy-compliant"></span>;
    }
    return <span className="energy-indicator energy-non-compliant"></span>;
  };

  const refreshData = () => {
    fetchChainStatus();
    setLastUpdate(Date.now());
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-violet-800 text-white">
      {/* Header */}
      <header className="bg-black/20 backdrop-blur-sm border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-4">
              <div className="quantum-pulse">
                <Activity className="h-8 w-8 text-violet-400" />
              </div>
              <div>
                <h1 className="text-xl font-bold bg-gradient-to-r from-violet-400 to-purple-400 bg-clip-text text-transparent">
                  VIOLET-AF PoAI Dashboard
                </h1>
                <p className="text-sm text-gray-400">Quantum-Powered Proof-of-AI Blockchain</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className={`w-2 h-2 rounded-full ${wsConnected ? 'bg-green-400' : 'bg-red-400'}`}></div>
                <span className="text-sm text-gray-300">
                  {wsConnected ? 'Connected' : 'Disconnected'}
                </span>
              </div>
              <button
                onClick={refreshData}
                className="flex items-center space-x-2 px-3 py-2 bg-violet-600 hover:bg-violet-700 rounded-lg transition-colors"
              >
                <RefreshCw className="h-4 w-4" />
                <span className="text-sm">Refresh</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Chain Status Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="poai-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-400">Current Height</p>
                <p className="text-2xl font-bold text-white">
                  {chainStatus?.chainHead.height.toLocaleString() || '---'}
                </p>
              </div>
              <Database className="h-8 w-8 text-violet-400" />
            </div>
          </div>

          <div className="poai-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-400">Active Devices</p>
                <p className="text-2xl font-bold text-white">
                  {devices.filter(d => d.isOnline).length}
                </p>
              </div>
              <Users className="h-8 w-8 text-green-400" />
            </div>
          </div>

          <div className="poai-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-400">Pending Submissions</p>
                <p className="text-2xl font-bold text-white">
                  {chainStatus?.pendingSubmissions || '---'}
                </p>
              </div>
              <Clock className="h-8 w-8 text-yellow-400" />
            </div>
          </div>

          <div className="poai-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-400">Energy Compliant</p>
                <p className="text-2xl font-bold text-white">
                  {devices.filter(d => d.energyCompliant).length}/{devices.length}
                </p>
              </div>
              <Zap className="h-8 w-8 text-green-400" />
            </div>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="poai-card">
            <h3 className="text-lg font-semibold mb-4 flex items-center">
              <BarChart3 className="h-5 w-5 mr-2 text-violet-400" />
              Block Height Progress
            </h3>
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={blockHeightData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="time" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }} 
                />
                <Line 
                  type="monotone" 
                  dataKey="height" 
                  stroke="#8B5CF6" 
                  strokeWidth={2}
                  dot={{ fill: '#8B5CF6' }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="poai-card">
            <h3 className="text-lg font-semibold mb-4 flex items-center">
              <Activity className="h-5 w-5 mr-2 text-violet-400" />
              PoAI Submissions
            </h3>
            <ResponsiveContainer width="100%" height={200}>
              <AreaChart data={blockHeightData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="time" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }} 
                />
                <Area 
                  type="monotone" 
                  dataKey="submissions" 
                  stroke="#10B981" 
                  fill="url(#submissionsGradient)"
                />
                <defs>
                  <linearGradient id="submissionsGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#10B981" stopOpacity={0.1}/>
                  </linearGradient>
                </defs>
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Device Status */}
        <div className="poai-card mb-8">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Shield className="h-5 w-5 mr-2 text-violet-400" />
            Mobile Validator Status
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-gray-700">
                  <th className="pb-3 text-sm font-medium text-gray-400">Device</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">Status</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">Battery</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">CPU Temp</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">Energy Policy</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">Last Submission</th>
                  <th className="pb-3 text-sm font-medium text-gray-400">Total</th>
                </tr>
              </thead>
              <tbody>
                {devices.map((device, index) => (
                  <tr key={device.deviceId} className="border-b border-gray-800">
                    <td className="py-3">
                      <div className="flex items-center">
                        <Wifi className="h-4 w-4 mr-2 text-gray-400" />
                        <span className="font-mono text-sm">{device.deviceId}</span>
                      </div>
                    </td>
                    <td className="py-3">
                      <span className={`network-status ${device.isOnline ? 'status-active' : 'status-inactive'}`}>
                        {device.isOnline ? 'Online' : 'Offline'}
                      </span>
                    </td>
                    <td className="py-3">
                      <div className="flex items-center space-x-2">
                        <Battery className="h-4 w-4 text-green-400" />
                        <span>{device.batteryLevel}%</span>
                        {device.isCharging && <Zap className="h-3 w-3 text-yellow-400" />}
                      </div>
                    </td>
                    <td className="py-3">
                      <div className="flex items-center space-x-2">
                        <Thermometer className="h-4 w-4 text-blue-400" />
                        <span>{device.cpuTemperature}°C</span>
                      </div>
                    </td>
                    <td className="py-3">
                      <div className="flex items-center space-x-2">
                        {getEnergyStatus(device)}
                        <span className="text-sm">
                          {device.energyCompliant ? 'Compliant' : 'Non-compliant'}
                        </span>
                      </div>
                    </td>
                    <td className="py-3 text-sm text-gray-400">
                      {formatTime(device.lastSubmission)}
                    </td>
                    <td className="py-3 text-sm">
                      {device.totalSubmissions.toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Recent Digests */}
        <div className="poai-card">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Cpu className="h-5 w-5 mr-2 text-violet-400" />
            Recent PoAI Digests
          </h3>
          <div className="space-y-3">
            {chainStatus?.recentDigests.map((digest, index) => (
              <div key={digest.height} className="flex items-center justify-between p-3 bg-gray-800/30 rounded-lg">
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-violet-400 rounded-full"></div>
                  <div>
                    <p className="font-mono text-sm text-white">{digest.digest}</p>
                    <p className="text-xs text-gray-400">Block #{digest.height}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm text-gray-400">{formatTime(digest.timestamp)}</p>
                  <div className="flex items-center text-xs text-green-400">
                    <CheckCircle className="h-3 w-3 mr-1" />
                    Verified
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Footer */}
        <footer className="mt-12 text-center text-gray-400 text-sm">
          <p>
            VIOLET-AF: Autonomous Quantum Logic Initialization & PoAI Stack v1.0.0
          </p>
          <p className="mt-1">
            Created by Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
          </p>
          <p className="mt-1">
            Licensed under UCL-∞ | Last updated: {formatTime(lastUpdate)}
          </p>
        </footer>
      </main>
    </div>
  );
}

export default App;