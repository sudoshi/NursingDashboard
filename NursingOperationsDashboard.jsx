/**
 * NursingOperationsDashboard.jsx
 * 
 * A comprehensive dashboard for healthcare operations management featuring:
 * - ML model performance monitoring
 * - Cross-department analytics
 * - Advanced alert configuration
 * - Real-time data streaming
 * - Patient flow visualization
 * - Resource utilization tracking
 * 
 * Requirements:
 * - React 18+
 * - @radix-ui/react-* components
 * - Recharts
 * - Lucide React icons
 * - Tailwind CSS
 */

import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Switch } from '@/components/ui/switch';
import { Brain, Activity, AlertCircle, Users, Clock, BedDouble, TrendingUp, RefreshCcw } from 'lucide-react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ScatterChart, Scatter 
} from 'recharts';

const NursingOperationsDashboard = () => {
  // ML model metrics including historical performance
  const [mlMetrics, setMlMetrics] = useState({
    currentPerformance: {
      accuracy: 0.92,
      precision: 0.89,
      recall: 0.87,
      f1Score: 0.88,
      auc: 0.91
    },
    historicalTrends: [
      { timestamp: '08:00', accuracy: 0.90, precision: 0.88, recall: 0.85 },
      { timestamp: '12:00', accuracy: 0.91, precision: 0.87, recall: 0.86 },
      { timestamp: '16:00', accuracy: 0.93, precision: 0.90, recall: 0.89 },
      { timestamp: '20:00', accuracy: 0.92, precision: 0.89, recall: 0.87 }
    ],
    featureImportance: {
      'Patient Age': 0.85,
      'Length of Stay': 0.78,
      'Admission Type': 0.92,
      'Previous Visits': 0.71,
      'Time of Day': 0.68
    }
  });

  // Cross-department comparative metrics
  const [comparativeMetrics, setComparativeMetrics] = useState({
    efficiency: {
      'Emergency': 0.85,
      'ICU': 0.92,
      'Surgery': 0.88,
      'General': 0.83
    },
    resourceUtilization: {
      'Emergency': 0.78,
      'ICU': 0.95,
      'Surgery': 0.82,
      'General': 0.75
    },
    patientOutcomes: {
      'Emergency': 0.88,
      'ICU': 0.91,
      'Surgery': 0.89,
      'General': 0.86
    }
  });

  // Advanced alert conditions with compound rules
  const [advancedAlertRules, setAdvancedAlertRules] = useState([
    {
      id: 1,
      name: 'Critical Resource Shortage',
      conditions: [
        { metric: 'staffingLevel', operator: 'below', threshold: 85 },
        { metric: 'patientVolume', operator: 'above', threshold: 90 },
        { timeWindow: '2h', minimumOccurrences: 3 }
      ],
      severity: 'critical',
      enabled: true
    },
    {
      id: 2,
      name: 'Capacity Warning',
      conditions: [
        { metric: 'bedOccupancy', operator: 'above', threshold: 85 },
        { metric: 'admissionRate', operator: 'increasing', timeWindow: '1h' },
        { metric: 'dischargeRate', operator: 'decreasing', timeWindow: '1h' }
      ],
      severity: 'warning',
      enabled: true
    }
  ]);

  // Simulated real-time data streaming
  useEffect(() => {
    const streamInterval = setInterval(() => {
      // Update ML metrics with slight variations
      setMlMetrics(prev => ({
        ...prev,
        currentPerformance: {
          ...prev.currentPerformance,
          accuracy: Math.min(1, prev.currentPerformance.accuracy + (Math.random() - 0.5) * 0.02)
        }
      }));

      // Update comparative metrics with random variations
      setComparativeMetrics(prev => ({
        ...prev,
        efficiency: Object.fromEntries(
          Object.entries(prev.efficiency).map(([key, value]) => [
            key,
            Math.min(1, Math.max(0, value + (Math.random() - 0.5) * 0.05))
          ])
        )
      }));
    }, 5000);

    return () => clearInterval(streamInterval);
  }, []);

  // ML Model Performance Component
  const MLModelPerformance = () => (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Brain />
            Real-Time Model Performance Metrics
          </CardTitle>
          <CardDescription>
            Continuous monitoring of model accuracy and reliability
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-4">
              {Object.entries(mlMetrics.currentPerformance).map(([metric, value]) => (
                <div key={metric} className="space-y-2">
                  <div className="flex justify-between">
                    <span className="capitalize">{metric.replace(/([A-Z])/g, ' $1')}</span>
                    <span className="font-semibold">{(value * 100).toFixed(1)}%</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full"
                      style={{ width: `${value * 100}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={mlMetrics.historicalTrends}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="timestamp" />
                  <YAxis domain={[0.8, 1]} />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="accuracy" stroke="#8884d8" />
                  <Line type="monotone" dataKey="precision" stroke="#82ca9d" />
                  <Line type="monotone" dataKey="recall" stroke="#ffc658" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Feature Importance Analysis</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={Object.entries(mlMetrics.featureImportance).map(([key, value]) => ({
                feature: key,
                importance: value * 100
              }))}>
                <PolarGrid />
                <PolarAngleAxis dataKey="feature" />
                <PolarRadiusAxis angle={30} domain={[0, 100]} />
                <Radar name="Importance" dataKey="importance" stroke="#8884d8" fill="#8884d8" fillOpacity={0.6} />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  // Cross-Department Analytics Component
  const DepartmentComparison = () => (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity />
            Comparative Department Performance
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={Object.keys(comparativeMetrics.efficiency).map(dept => ({
                department: dept,
                efficiency: comparativeMetrics.efficiency[dept] * 100,
                utilization: comparativeMetrics.resourceUtilization[dept] * 100,
                outcomes: comparativeMetrics.patientOutcomes[dept] * 100
              }))}>
                <PolarGrid />
                <PolarAngleAxis dataKey="department" />
                <PolarRadiusAxis angle={30} domain={[0, 100]} />
                <Radar name="Efficiency" dataKey="efficiency" stroke="#8884d8" fill="#8884d8" fillOpacity={0.6} />
                <Radar name="Resource Utilization" dataKey="utilization" stroke="#82ca9d" fill="#82ca9d" fillOpacity={0.6} />
                <Radar name="Patient Outcomes" dataKey="outcomes" stroke="#ffc658" fill="#ffc658" fillOpacity={0.6} />
                <Legend />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  // Advanced Alert Configuration Component
  const AdvancedAlertConfig = () => (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <AlertCircle />
          Advanced Alert Configuration
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {advancedAlertRules.map(rule => (
            <div key={rule.id} className="p-4 border rounded-lg space-y-4">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-semibold">{rule.name}</h3>
                  <Badge variant={rule.severity === 'critical' ? 'destructive' : 'default'}>
                    {rule.severity}
                  </Badge>
                </div>
                <Switch checked={rule.enabled} />
              </div>
              
              <div className="space-y-2">
                {rule.conditions.map((condition, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-sm">
                    <Badge variant="outline">
                      {condition.metric && `${condition.metric} ${condition.operator} ${condition.threshold}`}
                      {condition.timeWindow && `Within ${condition.timeWindow}`}
                      {condition.minimumOccurrences && `Min occurrences: ${condition.minimumOccurrences}`}
                    </Badge>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );

  // Real-time Data Streaming Component
  const RealTimeMetrics = () => (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <RefreshCcw className="animate-spin" />
          Live Metrics Stream
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span>Data Stream Status</span>
              <Badge variant="outline" className="animate-pulse">Active</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span>Update Frequency</span>
              <Badge>5 seconds</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span>Metrics Processing</span>
              <Badge variant="outline">Real-time</Badge>
            </div>
          </div>
          
          <div className="space-y-2">
            {Object.entries(mlMetrics.currentPerformance).slice(-3).map(([metric, value], idx) => (
              <div key={metric} className="flex items-center justify-between">
                <span className="capitalize">{metric.replace(/([A-Z])/g, ' $1')}</span>
                <Badge 
                  variant={value > 0.9 ? "default" : "outline"}
                  className="animate-pulse"
                >
                  {(value * 100).toFixed(1)}%
                </Badge>
              </div>
            ))}
          </div>
        </div>
      </CardContent>
    </Card>
  );

  return (
    <div className="w-full max-w-7xl mx-auto p-4 space-y-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Advanced Healthcare Analytics Platform</h1>
        <Badge variant="outline" className="animate-pulse">
          Live Updates Active
        </Badge>
      </div>

      <Tabs defaultValue="mlPerformance" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="mlPerformance">ML Performance</TabsTrigger>
          <TabsTrigger value="departmentComparison">Department Analysis</TabsTrigger>
          <TabsTrigger value="alertConfig">Alert Configuration</TabsTrigger>
          <TabsTrigger value="realTime">Real-Time Data</TabsTrigger>
        </TabsList>

        <TabsContent value="mlPerformance">
          <MLModelPerformance />
        </TabsContent>

        <TabsContent value="departmentComparison">
          <DepartmentComparison />
        </TabsContent>

        <TabsContent value="alertConfig">
          <AdvancedAlertConfig />
        </TabsContent>

        <TabsContent value="realTime">
          <RealTimeMetrics />
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default NursingOperationsDashboard;
