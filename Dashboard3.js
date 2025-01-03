import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Calendar, Clock, Users, Activity, TrendingUp, Bell, BedDouble, AlertCircle, Brain } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar, ScatterChart, Scatter } from 'recharts';

const NursingOperationsDashboard = () => {
  // Enhanced state management
  const [showAlert, setShowAlert] = useState(true);
  const [selectedTimeRange, setSelectedTimeRange] = useState('24h');
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [predictiveInsights, setPredictiveInsights] = useState({
    staffingGap: 3,
    peakTime: '14:00',
    expectedDischarges: 12,
    riskScore: 75
  });

  // Simulated real-time data updates
  useEffect(() => {
    const interval = setInterval(() => {
      // Simulate receiving new data and updating predictions
      setPredictiveInsights(prev => ({
        ...prev,
        staffingGap: Math.max(0, prev.staffingGap + Math.floor(Math.random() * 3) - 1),
        riskScore: Math.max(0, Math.min(100, prev.riskScore + Math.floor(Math.random() * 10) - 5))
      }));
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // Enhanced data structures with predictive elements
  const patientFlowPatterns = [
    { hour: '00:00', actual: 25, predicted: 28, historical: 26 },
    { hour: '04:00', actual: 22, predicted: 24, historical: 23 },
    { hour: '08:00', actual: 35, predicted: 38, historical: 36 },
    { hour: '12:00', actual: 45, predicted: 42, historical: 43 },
    { hour: '16:00', actual: 40, predicted: 39, historical: 41 },
    { hour: '20:00', actual: 30, predicted: 32, historical: 31 }
  ];

  // Enhanced scheduling data with AI recommendations
  const enhancedScheduling = [
    {
      shift: 'Morning',
      current: 42,
      recommended: 45,
      confidence: 0.85,
      factors: ['High admission rate', 'Multiple scheduled procedures']
    },
    {
      shift: 'Afternoon',
      current: 38,
      recommended: 40,
      confidence: 0.92,
      factors: ['Historical peak time', 'ED volume trend']
    },
    {
      shift: 'Night',
      current: 33,
      recommended: 35,
      confidence: 0.88,
      factors: ['Weekend pattern', 'Expected discharges']
    }
  ];

  // Predictive Analytics Component
  const PredictiveAnalytics = () => (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Brain className="h-5 w-5" />
          AI-Powered Insights
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card>
            <CardContent className="p-4">
              <h3 className="text-lg font-semibold mb-2">4-Hour Prediction</h3>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Expected Admissions:</span>
                  <Badge variant="outline">{predictiveInsights.expectedDischarges}</Badge>
                </div>
                <div className="flex justify-between">
                  <span>Staffing Gap Risk:</span>
                  <Badge 
                    variant={predictiveInsights.staffingGap > 2 ? "destructive" : "default"}
                  >
                    {predictiveInsights.staffingGap} staff needed
                  </Badge>
                </div>
                <div className="flex justify-between">
                  <span>Peak Time:</span>
                  <Badge variant="outline">{predictiveInsights.peakTime}</Badge>
                </div>
              </div>
            </CardContent>
          </Card>
          
          <Card>
            <CardContent className="p-4">
              <h3 className="text-lg font-semibold mb-2">Risk Assessment</h3>
              <div className="space-y-4">
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div 
                    className={`h-4 rounded-full ${
                      predictiveInsights.riskScore > 75 ? 'bg-red-500' :
                      predictiveInsights.riskScore > 50 ? 'bg-yellow-500' : 'bg-green-500'
                    }`}
                    style={{ width: `${predictiveInsights.riskScore}%` }}
                  ></div>
                </div>
                <div className="text-sm text-gray-600">
                  Risk Score: {predictiveInsights.riskScore}%
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </CardContent>
    </Card>
  );

  // Interactive Patient Flow Patterns
  const PatientFlowAnalysis = () => (
    <Card>
      <CardHeader>
        <CardTitle>Patient Flow Patterns</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-96">
          <ResponsiveContainer width="100%" height="100%">
            <ScatterChart>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="hour" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Scatter 
                name="Actual Flow" 
                data={patientFlowPatterns} 
                fill="#8884d8" 
                dataKey="actual"
              />
              <Scatter 
                name="Predicted Flow" 
                data={patientFlowPatterns} 
                fill="#82ca9d" 
                dataKey="predicted"
              />
              <Scatter 
                name="Historical Average" 
                data={patientFlowPatterns} 
                fill="#ff7300" 
                dataKey="historical"
              />
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );

  // Enhanced Alert System
  const EnhancedAlerts = () => {
    const alerts = [
      {
        id: 1,
        type: 'critical',
        message: 'ED approaching capacity - Diversion risk high',
        action: 'Review staffing levels and bed availability'
      },
      {
        id: 2,
        type: 'warning',
        message: 'Predicted staffing shortage in ICU (Next 4 hours)',
        action: 'Consider staff reallocation'
      },
      {
        id: 3,
        type: 'info',
        message: 'Multiple discharges expected (2-4 PM)',
        action: 'Prepare discharge planning'
      }
    ].filter(alert => showAlert);

    return (
      <div className="space-y-2">
        {alerts.map(alert => (
          <Alert 
            key={alert.id}
            className={
              alert.type === 'critical' ? 'bg-red-50' :
              alert.type === 'warning' ? 'bg-yellow-50' : 'bg-blue-50'
            }
          >
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>{alert.message}</AlertTitle>
            <AlertDescription className="flex justify-between items-center">
              <span>{alert.action}</span>
              <Button 
                size="sm" 
                variant="outline"
                onClick={() => setShowAlert(false)}
              >
                Acknowledge
              </Button>
            </AlertDescription>
          </Alert>
        ))}
      </div>
    );
  };

  // Interactive Scheduling Interface
  const InteractiveScheduling = () => (
    <Card>
      <CardHeader>
        <CardTitle>AI-Enhanced Staff Scheduling</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {enhancedScheduling.map((shift) => (
            <div key={shift.shift} className="space-y-2">
              <div className="flex justify-between items-center">
                <span className="font-medium">{shift.shift} Shift</span>
                <div className="flex gap-2">
                  <Badge variant="outline">
                    Current: {shift.current}
                  </Badge>
                  <Badge 
                    variant={shift.current < shift.recommended ? "destructive" : "default"}
                  >
                    Recommended: {shift.recommended}
                  </Badge>
                </div>
              </div>
              <div className="text-sm text-gray-600">
                Confidence: {(shift.confidence * 100).toFixed(0)}%
              </div>
              <div className="text-sm text-gray-600">
                Factors: {shift.factors.join(', ')}
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2.5">
                <div 
                  className="bg-blue-600 h-2.5 rounded-full"
                  style={{ width: `${(shift.current/shift.recommended) * 100}%` }}
                ></div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );

  return (
    <div className="w-full max-w-7xl mx-auto p-4 space-y-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">
          Advanced Nursing Operations Dashboard
        </h1>
        <div className="flex gap-2">
          <Badge variant="destructive" className="animate-pulse">
            {predictiveInsights.staffingGap} Staff Needed
          </Badge>
        </div>
      </div>

      <EnhancedAlerts />

      <Tabs defaultValue="predictive" className="w-full">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="predictive">Predictive Analytics</TabsTrigger>
          <TabsTrigger value="flow">Patient Flow</TabsTrigger>
          <TabsTrigger value="scheduling">Interactive Scheduling</TabsTrigger>
          <TabsTrigger value="alerts">Alert Management</TabsTrigger>
          <TabsTrigger value="insights">AI Insights</TabsTrigger>
        </TabsList>

        <TabsContent value="predictive">
          <PredictiveAnalytics />
        </TabsContent>

        <TabsContent value="flow">
          <PatientFlowAnalysis />
        </TabsContent>

        <TabsContent value="scheduling">
          <InteractiveScheduling />
        </TabsContent>

        <TabsContent value="alerts">
          <Card>
            <CardHeader>
              <CardTitle>Alert Configuration</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {/* Alert configuration interface would go here */}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="insights">
          <Card>
            <CardHeader>
              <CardTitle>AI-Generated Insights</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {/* AI insights interface would go here */}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default NursingOperationsDashboard;