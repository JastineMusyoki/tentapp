import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tentapp/controller/admin_controller.dart';

class UserDeliveriesScreen extends StatefulWidget {
  @override
  State<UserDeliveriesScreen> createState() => _UserDeliveriesScreenState();
}

class _UserDeliveriesScreenState extends State<UserDeliveriesScreen> {
  final AdminController _adminController = Get.find<AdminController>();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _adminController.fetchDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deliveries'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Obx(() {
        if (_adminController.isLoading.value) {
          return Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Processing...')
              ],
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.green], // Adjust colors as needed
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _buildDeliveriesCarousel(),
                ),
                _buildJumpingDotIndicators(),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildDeliveriesCarousel() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _currentPage = (_currentPage - 1)
                  .clamp(0, _adminController.deliveries.length - 1);
            });
          },
        ),
        Expanded(
          child: PageView.builder(
            itemCount: _adminController.deliveries.length,
            controller: PageController(initialPage: _currentPage),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final delivery = _adminController.deliveries[index];
              return Center(
                child: Card(
                  margin: EdgeInsets.all(16.0),
                  elevation: 4.0,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 300,
                          child: ListTile(
                            title: Text('Delivery ID: ${delivery.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Number: ${delivery.orderId}'),
                                SizedBox(height: 4.0),
                                Text('Driver Details: ${delivery.driverName}'),
                                Text('Phone Number: ${delivery.phoneNumber}'),
                                Text(
                                    'Vehicle Number Plate: ${delivery.vehicleNumberPlate}'),
                                Text(
                                    'Vehicle Description: ${delivery.vehicleDescription}'),
                                Text(
                                    'Delivery Status: ${delivery.isDelivered ? 'Delivered' : 'Not Delivered'}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        //  top: 0,
                        //  right: 0,
                        child: DropdownButton<String>(
                          value: 'Select Action',
                          onChanged: (String? value) {
                            if (value == 'Update Status') {
                              // Navigate to screen to update delivery status
                              _adminController.updateDeliveryStatus(
                                delivery.id,
                                true, // Assuming you want to mark it as delivered
                              );
                            }
                            // else
                            // if (value == 'Delete') {
                            //   // Delete delivery
                            //   _adminController.deleteDelivery(delivery.id);
                            // }
                          },
                          items: <String>['Select Action', 'Update Status']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              _currentPage = (_currentPage + 1)
                  .clamp(0, _adminController.deliveries.length - 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildJumpingDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _adminController.deliveries.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: index == _currentPage ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: index == _currentPage ? Colors.amber : Colors.grey,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
