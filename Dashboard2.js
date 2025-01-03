import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Switch } from '@/components/ui/switch';
import { Calendar, Clock, Users, Activity, TrendingUp, Bell, BedDouble, AlertCircle, Brain } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis } from 'recharts';

const NursingOperationsDashboard = () => {
  // Enhanced state for ML confidence and department analytics
  const [mlConfidence, setMlConfidence] = useState({
    staffing: 0.87,
    admissions: 0.92,
    discharges: 0.85,
    bedAllocation: 0.89
  });

  // Department-specific metrics
  const [departmentMetrics, setDepartmentMetrics] = useState({
    'Emergency': {
      occupancy: 85,
      waitTime: 45,
      staffingLevel: 92,
      patientSatisfaction: 88,
      predictedDemand: 'increasing'
    },
    'ICU': {
      occupancy: 78,
      waitTime: 15,
      staffingLevel: 95,
      patientSatisfaction: 91,
      predictedDemand: 'stable'
    },
    'Surgery': {
      occupancy: 72,
      waitTime: 30,
      staffingLevel: 88,
      patientSatisfaction: 85,
      predictedDemand: 'decreasing'
    },
    'General': {
      occupancy: 80,
      waitTime: 25,
      staffingLevel: 90,
      patientSatisfaction: 87,
      predictedDemand: 'stable'
    }
  });

  // Custom alert rules state
  const [alertRules, setAlertRules] = useState([
    {
      id: 1,
      name: 'High Occupancy Alert',
      metric: 'occupancy',
      threshold: 85,
      enabled: true,
      severity: 'high',
      departments: ['Emergency', 'ICU']
    },
    {
      id: 2,
      name: 'Wait Time Warning',
      metric: 'waitTime',
      threshold: 40,
      enabled: true,
      severity: 'medium',
      departments: ['Emergency']
    },
    {
      id: 3,
      name: 'Staff Coverage Alert',
      metric: 'staffingLevel',
      threshold: 85,
      enabled: true,
      severity: 'high',
      departments: ['all']
    }
  ]);

  // ML Model Confidence Visualization Component
  const MLConfidenceDisplay = () => {
    const confidenceData = Object.entries(mlConfidence).map(([key, value]) => ({
      subject: key,
      confidence: value * 100
    }));

    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Brain />
            ML Model Confidence Metrics
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={confidenceData}>
                <PolarGrid />
                <PolarAngleAxis dataKey="subject" />
                <PolarRadiusAxis angle={30} domain={[0, 100]} />
                <Radar
                  name="Model Confidence"
                  dataKey="confidence"
                  stroke="#8884d8"
                  fill="#8884d8"
                  fillOpacity={0.6}
                />
              </RadarChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 space-y-2">
            {Object.entries(mlConfidence).map(([key, value]) => (
              <div key={key} className="flex justify-between items-center">
                <span className="capitalize">{key}</span>
                <div className="flex items-center gap-2">
                  <div className="w-32 bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full"
                      style={{ width: `${value * 100}%` }}
                    />
                  </div>
                  <span className="text-sm">{(value * 100).toFixed(1)}%</span>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  };

  // Department Analytics Component
  const DepartmentAnalytics = () => {
    const getStatusColor = (value, metric) => {
      const thresholds = {
        occupancy: { warning: 75, critical: 85 },
        waitTime: { warning: 30, critical: 45 },
        staffingLevel: { warning: 85, critical: 80 },
        patientSatisfaction: { warning: 85, critical: 80 }
      };

      const threshold = thresholds[metric];
      if (!threshold) return 'bg-blue-500';

      if (metric === 'staffingLevel' || metric === 'patientSatisfaction') {
        return value < threshold.critical ? 'bg-red-500' :
               value < threshold.warning ? 'bg-yellow-500' : 'bg-green-500';
      }

      return value > threshold.critical ? 'bg-red-500' :
             value > threshold.warning ? 'bg-yellow-500' : 'bg-green-500';
    };

    return (
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {Object.entries(departmentMetrics).map(([dept, metrics]) => (
          <Card key={dept}>
            <CardHeader>
              <CardTitle>{dept} Department</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {Object.entries(metrics).map(([metric, value]) => (
                <div key={metric} className="space-y-2">
                  <div className="flex justify-between">
                    <span className="capitalize">{metric.replace(/([A-Z])/g, ' $1').trim()}</span>
                    <span>
                      {typeof value === 'number' ? 
                        (metric === 'waitTime' ? `${value} mins` : `${value}%`) :
                        value}
                    </span>
                  </div>
                  {typeof value === 'number' && (
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className={`${getStatusColor(value, metric)} h-2 rounded-full`}
                        style={{ width: `${value}%` }}
                      />
                    </div>
                  )}
                </div>
              ))}
            </CardContent>
          </Card>
        ))}
      </div>
    );
  };

  // Alert Rule Configuration Component
  const AlertRuleConfig = () => {
    const handleRuleToggle = (ruleId) => {
      setAlertRules(rules => 
        rules.map(rule => 
          rule.id === ruleId ? { ...rule, enabled: !rule.enabled } : rule
        )
      );
    };

    const handleThresholdChange = (ruleId, value) => {
      setAlertRules(rules =>
        rules.map(rule =>
          rule.id === ruleId ? { ...rule, threshold: value } : rule
        )
      );
    };

    return (
      <Card>
        <CardHeader>
          <CardTitle>Alert Rule Configuration</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {alertRules.map(rule => (
              <div key={rule.id} className="space-y-4 p-4 border rounded-lg">
                <div className="flex justify-between items-center">
                  <div>
                    <h3 className="font-semibold">{rule.name}</h3>
                    <p className="text-sm text-gray-500">
                      Applies to: {rule.departments.join(', ')}
                    </p>
                  </div>
                  <Switch
                    checked={rule.enabled}
                    onCheckedChange={() => handleRuleToggle(rule.id)}
                  />
                </div>

                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Threshold: {rule.threshold}%</span>
                    <Badge variant={rule.severity === 'high' ? 'destructive' : 'default'}>
                      {rule.severity}
                    </Badge>
                  </div>
                  <Slider
                    value={[rule.threshold]}
                    min={0}
                    max={100}
                    step={1}
                    className="w-full"
                    onValueChange={([value]) => handleThresholdChange(rule.id, value)}
                  />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  };

  return (
    <div className="w-full max-w-7xl mx-auto p-4 space-y-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Advanced Healthcare Analytics Dashboard</h1>
        <Badge variant="outline" className="text-lg">
          ML Confidence: {(Object.values(mlConfidence).reduce((a, b) => a + b, 0) / Object.values(mlConfidence).length * 100).toFixed(1)}%
        </Badge>
      </div>

      <Tabs defaultValue="mlConfidence" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="mlConfidence">ML Model Confidence</TabsTrigger>
          <TabsTrigger value="departments">Department Analytics</TabsTrigger>
          <TabsTrigger value="alertRules">Alert Rules</TabsTrigger>
          <TabsTrigger value="scheduling">Scheduling</TabsTrigger>
        </TabsList>

        <TabsContent value="mlConfidence">
          <MLConfidenceDisplay />
        </TabsContent>

        <TabsContent value="departments">
          <DepartmentAnalytics />
        </TabsContent>

        <TabsContent value="alertRules">
          <AlertRuleConfig />
        </TabsContent>

        <TabsContent value="scheduling">
          {/* Enhanced scheduling interface would go here */}
          <Card>
            <CardHeader>
              <CardTitle>Interactive Staff Scheduling</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-8 text-gray-500">
                Drag-and-drop scheduling interface coming soon
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default NursingOperationsDashboard;