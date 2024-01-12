import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bo/cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ConfirmationPage extends StatefulWidget {
  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  ValueNotifier<String?> selectedPaymentMethod = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<Cart>();
    double subtotal = cart.calculateSubtotal();
    double tax = subtotal * 0.2;
    double total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalisation de la commande'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          OrderSummaryCard(subtotal: subtotal, tax: tax, total: total),
          DeliveryAddressCard(),
          PaymentMethodsCard(selectedPaymentMethod: selectedPaymentMethod),
          TermsAndConditionsText(),
          ConfirmPurchaseButton(selectedPaymentMethod: selectedPaymentMethod),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const OrderSummaryCard({
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: const Text('Récapitulatif de votre commande'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sous-Total: ${subtotal.toStringAsFixed(2)}€'),
            Text('TVA: ${tax.toStringAsFixed(2)}€'),
            Text('TOTAL: ${total.toStringAsFixed(2)}€'),
          ],
        ),
      ),
    );
  }
}

class DeliveryAddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const ListTile(
        title: Text('Adresse de livraison'),
        subtitle: Text(
            'Michel Le Poney\n8 rue des ouvertues de portes\n93204 CORBEAUX'),
      ),
    );
  }
}

class PaymentMethodsCard extends StatelessWidget {
  final ValueNotifier<String?> selectedPaymentMethod;

  const PaymentMethodsCard({required this.selectedPaymentMethod});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildPaymentMethodButton(
              FontAwesomeIcons.applePay,
              'ApplePay',
            ),
            buildPaymentMethodButton(
              FontAwesomeIcons.ccVisa,
              'Visa',
            ),
            buildPaymentMethodButton(
              FontAwesomeIcons.ccMastercard,
              'MasterCard',
            ),
            buildPaymentMethodButton(
              FontAwesomeIcons.paypal,
              'PayPal',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodButton(IconData icon, String paymentMethod) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedPaymentMethod,
      builder: (context, value, child) {
        bool isSelected = value == paymentMethod;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          child: FaIcon(icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black),
          onPressed: () {
            selectedPaymentMethod.value = paymentMethod;
          },
        );
      },
    );
  }
}

class TermsAndConditionsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'En cliquant sur "Confirmer l\'achat", vous acceptez les Conditions de vente de EPSI Shop International. Besoin d\'aide ? Désolé on peut rien faire.\nEn poursuivant, vous acceptez les Conditions d\'utilisation du fournisseur de paiement CoffeeDis.',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ConfirmPurchaseButton extends StatelessWidget {
  final ValueNotifier<String?> selectedPaymentMethod;

  const ConfirmPurchaseButton({required this.selectedPaymentMethod});

  Future<void> sendPostRequest(BuildContext context, String total,
      String adresse, String paiement) async {
    var url = Uri.parse('http://ptsv3.com/t/EPSISHOPC1/');
    var body = jsonEncode(<String, String>{
      'total': total,
      'adresse': adresse,
      'paiement': paiement,
    });

    var response = await http
        .post(url, body: body, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      print('Request successful');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commande réussie'), duration: Duration(milliseconds: 500),));
      Provider.of<Cart>(context, listen: false).clearCart();
      GoRouter.of(context).go('/');
    } else {
      print('Request failed with status: ${response.statusCode}.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de la commande'), duration: Duration(milliseconds: 500),));
    }
  }

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<Cart>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ValueListenableBuilder<String?>(
        valueListenable: selectedPaymentMethod,
        builder: (context, value, child) {
          return ElevatedButton(
            onPressed: value != null
                ? () {
                    sendPostRequest(context, cart.priceTotalInEuro(), 'adresse',
                        'paiement');
                  }
                : null,
            child: const Text('Confirmer l\'achat'),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        },
      ),
    );
  }
}
