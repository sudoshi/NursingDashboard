import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Clock, Users, Activity, TrendingUp } from 'lucide-react';

const NursingOperationsDashboard = () => {
  // Sample data - in real implementation this would come from your backend
  const staffingData = [
    { time: '00:00', predicted: 45, actual: 42 },
    { time: '04:00', predicted: 38, actual: 40 },
    { time: '08:00', predicted: 52, actual: 54 },
    { time: '12:00', predicted: 65, actual: 63 },
    { time: '16:00', predicted: 58, actual: 56 },
    { time: '20:00', predicted: 48, actual: 47 }
  ];

  const throughputData = [
    { hour: '00:00', admissions: 8, discharges: 5 },
    { hour: '04:00', admissions: 6, discharges: 4 },
    { hour: '08:00', admissions: 12, discharges: 10 },
    { hour: '12:00', admissions: 15, discharges: 18 },
    { hour: '16:00', admissions: 10, discharges: 12 },
    { hour: '20:00', admissions: 7, discharges: 8 }
  ];

  return (
    <div className="w-full max-w-7xl mx-auto p-4 space-y-4">
      <div className="text-2xl font-bold mb-6">
        Nursing Operations & Patient Throughput Dashboard
      </div>

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
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="staffing">Staffing Analytics</TabsTrigger>
          <TabsTrigger value="throughput">Patient Throughput</TabsTrigger>
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
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="throughput">
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
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default NursingOperationsDashboard;