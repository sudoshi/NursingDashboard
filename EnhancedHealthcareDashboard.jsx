/**
 * EnhancedHealthcareDashboard.jsx
 * 
 * A comprehensive healthcare operations management system featuring:
 * - Staff scheduling and management
 * - Bed management and patient flow
 * - Resource utilization tracking
 * - Real-time analytics and predictions
 * - Department performance monitoring
 * - Advanced alerting system
 */

import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Switch } from '@/components/ui/switch';
import { 
  Brain, Activity, AlertCircle, Users, Clock, BedDouble, 
  TrendingUp, RefreshCcw, Calendar, ChevronRight 
} from 'lucide-react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, 
  ResponsiveContainer, RadarChart, Radar, PolarGrid, PolarAngleAxis, 
  PolarRadiusAxis, BarChart, Bar, ScatterChart, Scatter 
} from 'recharts';

const EnhancedHealthcareDashboard = () => {
  // Staff scheduling and assignments
  const [staffSchedule, setStaffSchedule] = useState({
    shifts: [
      {
        id: 1,
        name: 'Morning',
        hours: '7:00 AM - 3:00 PM',
        requiredStaff: 45,
        assignedStaff: 42,
        departments: {
          'Emergency': 12,
          'ICU': 15,
          'General': 10,
          'Surgery': 5
        }
      },
      {
        id: 2,
        name: 'Afternoon',
        hours: '3:00 PM - 11:00 PM',
        requiredStaff: 40,
        assignedStaff: 38,
        departments: {
          'Emergency': 10,
          'ICU': 13,
          'General': 10,
          'Surgery': 5
        }
      },
      {
        id: 3,
        name: 'Night',
        hours: '11:00 PM - 7:00 AM',
        requiredStaff: 30,
        assignedStaff: 28,
        departments: {
          'Emergency': 8,
          'ICU': 10,
          'General': 7,
          'Surgery': 3
        }
      }
    ],
    staffPool: {
      total: 150,
      available: 135,
      onLeave: 10,
      training: 5
    }
  });

  // Bed management system
  const [bedManagement, setBedManagement] = useState({
    departments: {
      'Emergency': {
        total: 50,
        occupied: 42,
        available: 8,
        pending: 3,
        cleaning: 2
      },
      'ICU': {
        total: 30,
        occupied: 28,
        available: 2,
        pending: 1,
        cleaning: 1
      },
      'Surgery': {
        total: 40,
        occupied: 35,
        available: 5,
        pending: 2,
        cleaning: 1
      },
      'General': {
        total: 80,
        occupied: 65,
        available: 15,
        pending: 4,
        cleaning: 3
      }
    },
    predictions: {
      expectedAdmissions: 15,
      expectedDischarges: 12,
      peakOccupancyTime: '2:00 PM',
      bottleneckRisk: 'moderate'
    }
  });

  // Patient flow metrics
  const [patientFlow, setPatientFlow] = useState({
    currentMetrics: {
      avgWaitTime: 35,
      avgLOS: 4.2,
      bedTurnoverTime: 45,
      dischargeEfficiency: 0.85
    },
    hourlyFlow: [
      { hour: '08:00', admissions: 5, discharges: 3, transfers: 2 },
      { hour: '09:00', admissions: 7, discharges: 4, transfers: 3 },
      { hour: '10:00', admissions: 8, discharges: 6, transfers: 4 },
      { hour: '11:00', admissions: 6, discharges: 5, transfers: 2 },
      { hour: '12:00', admissions: 9, discharges: 7, transfers: 3 }
    ]
  });

  // Staff Scheduling Component
  const StaffSchedulingDashboard = () => (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar />
            Staff Scheduling Overview
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
            {staffSchedule.shifts.map(shift => (
              <Card key={shift.id} className="p-4">
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <h3 className="font-semibold">{shift.name}</h3>
                    <Badge variant={
                      shift.assignedStaff < shift.requiredStaff * 0.9 ? 'destructive' : 
                      shift.assignedStaff < shift.requiredStaff ? 'warning' : 'default'
                    }>
                      {shift.assignedStaff}/{shift.requiredStaff} Staff
                    </Badge>
                  </div>
                  <div className="text-sm text-gray-500">{shift.hours}</div>
                  <div className="space-y-2">
                    {Object.entries(shift.departments).map(([dept, count]) => (
                      <div key={dept} className="flex justify-between items-center text-sm">
                        <span>{dept}</span>
                        <Badge variant="outline">{count}</Badge>
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Staff Availability Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Total Staff</div>
              <div className="text-2xl font-bold">{staffSchedule.staffPool.total}</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Available</div>
              <div className="text-2xl font-bold text-green-600">
                {staffSchedule.staffPool.available}
              </div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">On Leave</div>
              <div className="text-2xl font-bold text-yellow-600">
                {staffSchedule.staffPool.onLeave}
              </div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">In Training</div>
              <div className="text-2xl font-bold text-blue-600">
                {staffSchedule.staffPool.training}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  // Bed Management Component
  const BedManagementDashboard = () => (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BedDouble />
            Bed Utilization by Department
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {Object.entries(bedManagement.departments).map(([dept, stats]) => (
              <Card key={dept} className="p-4">
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <h3 className="font-semibold">{dept}</h3>
                    <Badge variant={
                      stats.available < 2 ? 'destructive' :
                      stats.available < 5 ? 'warning' : 'default'
                    }>
                      {stats.available} Available
                    </Badge>
                  </div>
                  <div className="space-y-2">
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className={`h-2 rounded-full ${
                          (stats.occupied/stats.total) > 0.9 ? 'bg-red-500' :
                          (stats.occupied/stats.total) > 0.8 ? 'bg-yellow-500' : 'bg-green-500'
                        }`}
                        style={{ width: `${(stats.occupied/stats.total) * 100}%` }}
                      />
                    </div>
                    <div className="grid grid-cols-3 gap-2 text-sm">
                      <div>
                        <div className="text-gray-500">Occupied</div>
                        <div className="font-semibold">{stats.occupied}</div>
                      </div>
                      <div>
                        <div className="text-gray-500">Pending</div>
                        <div className="font-semibold">{stats.pending}</div>
                      </div>
                      <div>
                        <div className="text-gray-500">Cleaning</div>
                        <div className="font-semibold">{stats.cleaning}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Bed Capacity Predictions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Expected Admissions</div>
              <div className="text-2xl font-bold">{bedManagement.predictions.expectedAdmissions}</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Expected Discharges</div>
              <div className="text-2xl font-bold">{bedManagement.predictions.expectedDischarges}</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Peak Occupancy Time</div>
              <div className="text-2xl font-bold">{bedManagement.predictions.peakOccupancyTime}</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Bottleneck Risk</div>
              <div className="text-2xl font-bold capitalize">
                {bedManagement.predictions.bottleneckRisk}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  // Patient Flow Dashboard
  const PatientFlowDashboard = () => (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity />
            Patient Flow Metrics
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Avg Wait Time</div>
              <div className="text-2xl font-bold">{patientFlow.currentMetrics.avgWaitTime} min</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Avg Length of Stay</div>
              <div className="text-2xl font-bold">{patientFlow.currentMetrics.avgLOS} days</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Bed Turnover Time</div>
              <div className="text-2xl font-bold">{patientFlow.currentMetrics.bedTurnoverTime} min</div>
            </div>
            <div className="p-4 border rounded-lg">
              <div className="text-sm text-gray-500">Discharge Efficiency</div>
              <div className="text-2xl font-bold">
                {(patientFlow.currentMetrics.dischargeEfficiency * 100).toFixed(1)}%
              </div>
            </div>
          </div>

          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={patientFlow.hourlyFlow}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="hour" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="admissions" stroke="#8884d8" name="Admissions" />
                <Line type="monotone" dataKey="discharges" stroke="#82ca9d" name="Discharges" />
                <Line type="monotone" dataKey="transfers" stroke="#ffc658" name="Transfers" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  // Main dashboard layout
  return (
    <div className="w-full max-w-7xl mx-auto p-4 space-y-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Healthcare Operations Dashboard</h1>
        <Badge variant="outline" className="animate-pulse">
          Live Updates Active
        </Badge>
      </div>

      <Tabs defaultValue="staffing" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="staffing">Staff Scheduling</TabsTrig<TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="staffing">Staff Scheduling</TabsTrigger>
          <TabsTrigger value="beds">Bed Management</TabsTrigger>
          <TabsTrigger value="flow">Patient Flow</TabsTrigger>
        </TabsList>

        <TabsContent value="staffing">
          <StaffSchedulingDashboard />
        </TabsContent>

        <TabsContent value="beds">
          <BedManagementDashboard />
        </TabsContent>

        <TabsContent value="flow">
          <PatientFlowDashboard />
        </TabsContent>
      </Tabs>

      {/* Real-time Alerts Section */}
      <div className="mt-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertCircle />
              Active Alerts
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {/* High Priority Alert */}
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertTitle>ICU Bed Shortage</AlertTitle>
                <AlertDescription className="flex justify-between items-center">
                  <span>Only 2 ICU beds available. Expected admissions: 3</span>
                  <Button size="sm" variant="outline">
                    Take Action
                  </Button>
                </AlertDescription>
              </Alert>

              {/* Medium Priority Alert */}
              <Alert variant="warning">
                <Clock className="h-4 w-4" />
                <AlertTitle>Staff Coverage Warning</AlertTitle>
                <AlertDescription className="flex justify-between items-center">
                  <span>Night shift coverage below target in Emergency Department</span>
                  <Button size="sm" variant="outline">
                    Review Schedule
                  </Button>
                </AlertDescription>
              </Alert>

              {/* Informational Alert */}
              <Alert>
                <TrendingUp className="h-4 w-4" />
                <AlertTitle>Increased Patient Volume Expected</AlertTitle>
                <AlertDescription className="flex justify-between items-center">
                  <span>20% increase in ED visits predicted in next 4 hours</span>
                  <Button size="sm" variant="outline">
                    View Forecast
                  </Button>
                </AlertDescription>
              </Alert>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Performance Metrics Section */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
        <Card>
          <CardHeader>
            <CardTitle>Department Performance Summary</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={[
                  { department: 'ED', efficiency: 85, target: 90 },
                  { department: 'ICU', efficiency: 92, target: 90 },
                  { department: 'Surgery', efficiency: 88, target: 90 },
                  { department: 'General', efficiency: 83, target: 90 }
                ]}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="department" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="efficiency" fill="#8884d8" name="Current Efficiency" />
                  <Bar dataKey="target" fill="#82ca9d" name="Target" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Resource Utilization Trends</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={[
                  { time: '6:00', staff: 75, beds: 80, equipment: 65 },
                  { time: '9:00', staff: 85, beds: 85, equipment: 70 },
                  { time: '12:00', staff: 95, beds: 90, equipment: 80 },
                  { time: '15:00', staff: 90, beds: 88, equipment: 75 },
                  { time: '18:00', staff: 82, beds: 85, equipment: 70 }
                ]}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="time" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="staff" stroke="#8884d8" name="Staff Utilization" />
                  <Line type="monotone" dataKey="beds" stroke="#82ca9d" name="Bed Utilization" />
                  <Line type="monotone" dataKey="equipment" stroke="#ffc658" name="Equipment Usage" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Footer Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-center">98.5%</div>
            <div className="text-sm text-gray-500 text-center mt-2">System Uptime</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-center">2.3 min</div>
            <div className="text-sm text-gray-500 text-center mt-2">Avg Response Time</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-center">1,247</div>
            <div className="text-sm text-gray-500 text-center mt-2">Patients Today</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-center">94.2%</div>
            <div className="text-sm text-gray-500 text-center mt-2">Staff Satisfaction</div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default EnhancedHealthcareDashboard;
