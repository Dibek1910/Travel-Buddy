import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> rideDetails;

  const RideDetailsScreen({Key? key, required this.rideDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Text(
                            rideDetails['host']['firstName'][0] +
                                rideDetails['host']['lastName'][0],
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Host: ${rideDetails['host']['firstName']} ${rideDetails['host']['lastName']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Email: ${rideDetails['host']['email']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _buildDetailRow('From', rideDetails['from']),
                    _buildDetailRow('To', rideDetails['to']),
                    _buildDetailRow('Date', rideDetails['date']),
                    _buildDetailRow(
                        'Capacity', rideDetails['capacity'].toString()),
                    _buildDetailRow('Price', rideDetails['price'].toString()),
                    if (rideDetails['description'] != null &&
                        rideDetails['description'].toString().isNotEmpty)
                      _buildDetailRow(
                          'Description', rideDetails['description']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (rideDetails['requests'] != null &&
                rideDetails['requests'].length > 0)
              _buildRequestsSection(rideDetails['requests']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsSection(List<dynamic> requests) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ride Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final passenger = request['passenger'];
                final status = request['status'];

                Color statusColor;
                switch (status) {
                  case 'approved':
                    statusColor = Colors.green;
                    break;
                  case 'rejected':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      passenger['firstName'][0] + passenger['lastName'][0],
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  title: Text(
                      '${passenger['firstName']} ${passenger['lastName']}'),
                  subtitle: Text(passenger['email']),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
