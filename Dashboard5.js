import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { Clock, Users, Activity, TrendingUp, Bell, Calendar, BedDouble, AlertCircle } from 'lucide-react';

const NursingOperationsDashboard = () => {
  // State management for alerts and notifications
  const [showAlert, setShowAlert] = useState(true);
  const [activeView, setActiveView] = useState('dashboard');

  // Sample data structures
  const staffingData = [
    { time: '00:00', predicted: 45, actual: 42, capacity: 50 },
    { time: '04:00', predicted: 38, actual: 40, capacity: 50 },
    { time: '08:00', predicted: 52, actual: 54, capacity: 50 },
    { time: '12:00', predicted: 65, actual: 63, capacity: 50 },
    { time: '16:00', predicted: 58, actual: 56, capacity: 50 },
    { time: '20:00', predicted: 48, actual: 47, capacity: 50 }
  ];

  const throughputData = [
    { hour: '00:00', admissions: 8, discharges: 5, bedCapacity: 100, occupiedBeds: 85 },
    { hour: '04:00', admissions: 6, discharges: 4, bedCapacity: 100, occupiedBeds: 87 },
    { hour: '08:00', admissions: 12, discharges: 10, bedCapacity: 100, occupiedBeds: 89 },
    { hour: '12:00', admissions: 15, discharges: 18, bedCapacity: 100, occupiedBeds: 86 },
    { hour: '16:00', admissions: 10, discharges: 12, bedCapacity: 100, occupiedBeds: 84 },
    { hour: '20:00', admissions: 7, discharges: 8, bedCapacity: 100, occupiedBeds: 83 }
  ];

  const departmentBeds = [
    { department: 'ICU', total: 20, occupied: 18, pending: 2 },
    { department: 'Emergency', total: 30, occupied: 25, pending: 4 },
    { department: 'Surgery', total: 25, occupied: 20, pending: 3 },
    { department: 'General', total: 40, occupied: 32, pending: 5 }
  ];

  const staffSchedule = [
    { shift: 'Morning', required: 45, scheduled: 42, pending: 3 },
    { shift: 'Afternoon', required: 40, scheduled: 38, pending: 2 },
    { shift: 'Night', required: 35, scheduled: 33, pending: 2 }
  ];

  // Real-time alerts component
  const AlertsSection = () => (
    <div className="space-y-2">
      {showAlert && (
        <Alert className="bg-yellow-50">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>High Patient Volume Alert</AlertTitle>
          <AlertDescription>
            Emergency Department approaching capacity. Consider activating surge protocols.
          </AlertDescription>
          <Button 
            size="sm" 
            variant="outline"
            className="mt-2"
            onClick={() => setShowAlert(false)}
          >
            Acknowledge
          </Button>
        </Alert>
      )}
    </div>
  );

  // Bed Management component
  const BedManagement = () => (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <BedDouble className="h-5 w-5" />
          Bed Utilization by Department
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {departmentBeds.map((dept) => (
            <div key={dept.department} className="space-y-2">
              <div className="flex justify-between items-center">
                <span className="font-medium">{dept.department}</span>
                <Badge variant={dept.occupied/dept.total > 0.9 ? "destructive" : "default"}>
                  {dept.occupied}/{dept.total} Occupied
                </Badge>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2.5">
                <div 
                  className="bg-blue-600 h-2.5 rounded-full"
                  style={{ width: `${(dept.occupied/dept.total) * 100}%` }}
                ></div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );

  // Staff Scheduling component
  const StaffScheduling = () => (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Calendar className="h-5 w-5" />
          Staff Schedule Overview
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {staffSchedule.map((shift) => (
            <div key={shift.shift} className="space-y-2">
              <div className="flex justify-between items-center">
                <span className="font-medium">{shift.shift} Shift</span>
                <div className="flex gap-2">
                  <Badge variant="outline">{shift.scheduled}/{shift.required} Scheduled</Badge>
                  {shift.pending > 0 && (
                    <Badge variant="destructive">{shift.pending} Pending</Badge>
                  )}
                </div>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2.5">
                <div 
                  className="bg-green-600 h-2.5 rounded-full"
                  style={{ width: `${(shift.scheduled/shift.required) * 100}%` }}
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
          Nursing Operations & Patient Throughput Dashboard
        </h1>
        <div className="flex gap-2">
          {showAlert && (
            <Badge variant="destructive" className="animate-pulse">
              1 Active Alert
            </Badge>
          )}
        </div>
      </div>

      <AlertsSection />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2">
              <Users className="h-8 w-8 text-blue-500" />
              <div>
                <p className="text-sm text-gray-500">Current Staff</p>
                <p className="text-2xl font-bold">127/130</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2">
              <Activity className="h-8 w-8 text-green-500" />
              <div>
                <p className="text-sm text-gray-500">Bed Occupancy</p>
                <p className="text-2xl font-bold">85%</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2">
              <Clock className="h-8 w-8 text-yellow-500" />
              <div>
                <p className="text-sm text-gray-500">Avg Wait Time</p>
                <p className="text-2xl font-bold">42 min</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center space-x-2">
              <TrendingUp className="h-8 w-8 text-purple-500" />
              <div>
                <p className="text-sm text-gray-500">Patient Satisfaction</p>
                <p className="text-2xl font-bold">92%</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="staffing" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="staffing">Staffing Analytics</TabsTrigger>
          <TabsTrigger value="throughput">Patient Throughput</TabsTrigger>
          <TabsTrigger value="beds">Bed Management</TabsTrigger>
          <TabsTrigger value="schedule">Staff Scheduling</TabsTrigger>
        </TabsList>

        <TabsContent value="staffing">
          <Card>
            <CardHeader>
              <CardTitle>Staffing Predictions vs Actual</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-96">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={staffingData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="time" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line 
                      type="monotone" 
                      dataKey="predicted" 
                      stroke="#8884d8" 
                      name="Predicted Staff Needed"
                    />
                    <Line 
                      type="monotone" 
                      dataKey="actual" 
                      stroke="#82ca9d" 
                      name="Actual Staff"
                    />
                    <Line 
                      type="monotone" 
                      dataKey="capacity" 
                      stroke="#ff7300" 
                      name="Maximum Capacity"
                      strokeDasharray="5 5"
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="throughput">
          <div className="grid gap-4">
            <Card>
              <CardHeader>
                <CardTitle>Patient Flow Analysis</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="h-96">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={throughputData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="hour" />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Line 
                        type="monotone" 
                        dataKey="admissions" 
                        stroke="#8884d8" 
                        name="Admissions"
                      />
                      <Line 
                        type="monotone" 
                        dataKey="discharges" 
                        stroke="#82ca9d" 
                        name="Discharges"
                      />
                      <Line 
                        type="monotone" 
                        dataKey="occupiedBeds" 
                        stroke="#ff7300" 
                        name="Occupied Beds"
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="beds">
          <BedManagement />
        </TabsContent>

        <TabsContent value="schedule">
          <StaffScheduling />
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default NursingOperationsDashboard;