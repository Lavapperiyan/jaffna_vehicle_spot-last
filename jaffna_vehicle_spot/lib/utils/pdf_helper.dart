import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/staff.dart';
import '../models/customer.dart';
import '../models/attendance.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static Future<pw.Document> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Load logo
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Logo and Name
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Image(logoImage, width: 80),
                      pw.SizedBox(height: 10),
                      pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('REG.NO : PV00250669',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ],
                  ),
                  pw.Spacer(),
                  // Middle: Branches
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 20),
                      pw.Text('Branches',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      pw.Text('• K.K.S Road, Kokuvil West, Jaffna',
                          style: pw.TextStyle(fontSize: 8)),
                      pw.Text('• A9 Road, Parant han, Kilinochchi.',
                          style: pw.TextStyle(fontSize: 8)),
                      pw.Text('• No.501/49 Trinco Road, Batticaloa.',
                          style: pw.TextStyle(fontSize: 8)),
                      pw.Text('Pastcode: 40000',
                          style: pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  // Right: Contact with icons
                  pw.Row(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(height: 15),
                          pw.Text('077 844 9700', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.Text('021 221 4813', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 12),
                          pw.Text('rathees.rathees@gamil.com', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          pw.Text('Jaffna', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(width: 5),
                      pw.Container(
                        width: 20,
                        height: 70,
                        color: PdfColors.black,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            pw.Icon(const pw.IconData(0xe0b0), color: PdfColors.white, size: 10), // Phone
                            pw.Icon(const pw.IconData(0xe158), color: PdfColors.white, size: 10), // Email
                            pw.Icon(const pw.IconData(0xe0c8), color: PdfColors.white, size: 10), // Location
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              // Title Section
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.red),
                    pw.SizedBox(height: 5),
                    pw.Text('VEHICLE SALE INVOICE',
                        style: pw.TextStyle(
                          color: PdfColors.red,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 5),
                    pw.Container(width: 150, height: 1, color: PdfColors.red),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Identifiers Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'Invoice No: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: 'JVSL/2025/${invoice.id.split('-').last}', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: invoice.date.replaceAll('-', ' / '), style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Customer Details
              _buildUnderlineInfoRow('Delivered To:', invoice.customerName),
              _buildUnderlineInfoRow('Address:', invoice.customerAddress),
              _buildUnderlineInfoRow('Contact No:', invoice.customerContact),

              pw.SizedBox(height: 20),
              pw.Text('Vehicle Details:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Two column vehicle details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.SizedBox(width: 150, child: pw.Text('Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                ],
              ),
              _buildVehicleDetailRow('Make & Model', invoice.vehicleName),
              _buildVehicleDetailRow('Year of Manufacture', invoice.year),
              _buildVehicleDetailRow('Engine No.', invoice.engineNo),
              _buildVehicleDetailRow('Chassis No.', invoice.chassisNo),
              _buildVehicleDetailRow('Vehicle Type', invoice.vehicleType),
              _buildVehicleDetailRow('Fuel Type', invoice.fuelType),
              _buildVehicleDetailRow('Colour', invoice.color),
              _buildVehicleDetailRow('Registration No.', invoice.registrationNo),

              pw.SizedBox(height: 30),
              pw.Text('Total Amount & Lease:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Summary Table
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Total Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(text: 'LKR ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                              pw.TextSpan(text: invoice.amount, style: pw.TextStyle(fontSize: 8, decoration: pw.TextDecoration.underline)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text('Declaration:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(
                'I hereby acknowledge that I have received the above-mentioned vehicle from Jaffna Vehicle Spot (Pvt) Ltd in good condition and verified all the details.',
                style: const pw.TextStyle(fontSize: 8),
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'Customer Signature: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.TextSpan(text: '___________________', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.TextSpan(text: '__ / __ / 2025', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'Authorized Signature: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.TextSpan(text: '___________________', style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildUnderlineInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 80, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
              child: pw.Text(value.toUpperCase(), style: const pw.TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(
            width: 150,
            child: pw.Container(
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
              child: pw.Text(value.toUpperCase(), style: const pw.TextStyle(fontSize: 8)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Text(' : ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(child: pw.Text(value.toUpperCase(), style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static Future<void> viewPdf(Invoice invoice) async {
    final pdf = await generateInvoicePdf(invoice);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> downloadPdf(Invoice invoice) async {
    final pdf = await generateInvoicePdf(invoice);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${invoice.id}.pdf');
  }

  static Future<pw.Document> generateStaffPdf(Staff staff) async {
    final pdf = pw.Document();

    // Load logo
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(logoImage, height: 60),
                        pw.SizedBox(height: 10),
                        pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text('Reg.No : PV00250669', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('077 844 9700', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('rathees.rathees@gmail.com', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('K.K.S Road, Kokuvil West, Jaffna', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Center(child: pw.Text('STAFF DETAILS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline))),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),

                pw.Text('PERSONAL INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(),
                _buildPdfInfoRow('ID', staff.id),
                _buildPdfInfoRow('Full Name', staff.fullName),
                _buildPdfInfoRow('Role', staff.roleDisplay),
                _buildPdfInfoRow('Date of Birth', staff.dob),
                _buildPdfInfoRow('NIC No', staff.nicNo),
                _buildPdfInfoRow('Gender', staff.gender),
                _buildPdfInfoRow('Civil Status', staff.civilStatus),

                pw.SizedBox(height: 15),
                pw.Text('CONTACT INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(),
                _buildPdfInfoRow('Mobile No', staff.mobileNo),
                _buildPdfInfoRow('Home No', staff.homeNo),
                _buildPdfInfoRow('Email', staff.email),
                _buildPdfInfoRow('Postal Address', staff.postalAddress),
                _buildPdfInfoRow('Permanent Address', staff.permanentAddress),

                pw.SizedBox(height: 15),
                pw.Text('EMPLOYMENT & BANKING', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(),
                _buildPdfInfoRow('Joined Date', staff.joinDate),
                _buildPdfInfoRow('Branch', staff.branch),
                _buildPdfInfoRow('Salary', 'Rs. ${staff.salaryAmount}'),
                _buildPdfInfoRow('Bank', staff.bankName),
                _buildPdfInfoRow('Account No', staff.accountNo),
                _buildPdfInfoRow('EPF No', staff.epfNo),

                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('................................'),
                        pw.Text('Staff Signature', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('................................'),
                        pw.Text('Director Signature', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> viewStaffPdf(Staff staff) async {
    final pdf = await generateStaffPdf(staff);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> downloadStaffPdf(Staff staff) async {
    final pdf = await generateStaffPdf(staff);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'staff_${staff.id}.pdf');
  }

  static Future<pw.Document> generateCustomerPdf(Customer customer) async {
    final pdf = pw.Document();

    // Load logo
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(logoImage, height: 60),
                        pw.SizedBox(height: 10),
                        pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text('Reg.No : PV00250669', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('077 844 9700', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('rathees.rathees@gmail.com', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('K.K.S Road, Kokuvil West, Jaffna', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Center(child: pw.Text('CUSTOMER DETAILS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline))),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),

                pw.Text('CUSTOMER INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(),
                _buildPdfInfoRow('Customer ID', customer.id),
                _buildPdfInfoRow('Full Name', customer.name),
                _buildPdfInfoRow('NIC No', customer.nic),
                _buildPdfInfoRow('Phone No', customer.phone),
                _buildPdfInfoRow('Email', customer.email),
                _buildPdfInfoRow('Address', customer.address),
                _buildPdfInfoRow('Register Date', customer.joinDate),

                pw.SizedBox(height: 15),
                pw.Text('PURCHASED VEHICLES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(),
                ...InvoiceService().invoicesNotifier.value
                    .where((inv) => inv.customerNic == customer.nic)
                    .map((inv) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(inv.vehicleName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue)),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10, top: 4, bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildPdfInfoRow('Reg No', inv.registrationNo),
                              _buildPdfInfoRow('Chassis No', inv.chassisNo),
                              _buildPdfInfoRow('Engine No', inv.engineNo),
                              _buildPdfInfoRow('Date', inv.date),
                              _buildPdfInfoRow('Amount', 'Rs. ${inv.amount}'),
                            ],
                          ),
                        ),
                      ],
                    )),
                if (InvoiceService().invoicesNotifier.value.where((inv) => inv.customerNic == customer.nic).isEmpty)
                  pw.Text('No vehicles purchased yet.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),

                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('................................'),
                        pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('................................'),
                        pw.Text('Date', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> viewCustomerPdf(Customer customer) async {
    final pdf = await generateCustomerPdf(customer);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> downloadCustomerPdf(Customer customer) async {
    final pdf = await generateCustomerPdf(customer);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'customer_${customer.id}.pdf');
  }

  static Future<pw.Document> generateSalesReportPdf(List<Invoice> invoices, String title) async {
    final pdf = pw.Document();

    // Load logo
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(logoImage, height: 40),
                    pw.SizedBox(height: 5),
                    pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text('Sales Report - $title', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated on:', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(DateTime.now().toString().split('.')[0], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (pw.Context context) {
          double totalAmount = 0;
          for (var inv in invoices) {
            final amt = double.tryParse(inv.amount.replaceAll(',', '')) ?? 0;
            totalAmount += amt;
          }

          return [
            pw.TableHelper.fromTextArray(
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              headerPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              data: <List<String>>[
                <String>['Date', 'Invoice ID', 'Customer', 'Amount (LKR)'],
                ...invoices.map((inv) => [
                      inv.date,
                      inv.id,
                      inv.customerName,
                      inv.amount,
                    ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Total Sales Count: ${invoices.length}', style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Grand Total: LKR ${totalAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blue900),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Jaffna Vehicle Spot (Pvt) Ltd', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  static Future<void> downloadSalesReportPdf(List<Invoice> invoices, String title) async {
    final pdf = await generateSalesReportPdf(invoices, title);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'sales_report_${title.replaceAll(' ', '_')}.pdf');
  }
  
  static Future<pw.Document> generateStaffUsageAuditPdf(List<Attendance> attendances, String title) async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Image(logoImage, height: 45),
                      pw.SizedBox(height: 8),
                      pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900)),
                      pw.Text('Staff Application Usage & Audit Report', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Period: $title', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                ),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Report Generated:', style: pw.TextStyle(fontSize: 8)),
                      pw.Text(DateFormat('MMM d, yyyy @ HH:mm').format(DateTime.now()), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const pw.BoxDecoration(color: PdfColors.green100),
                        child: pw.Text('OFFICIAL AUDIT', style: pw.TextStyle(fontSize: 7, color: PdfColors.green900, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1.5, color: PdfColors.blue900),
            pw.SizedBox(height: 15),
          ],
        ),
        build: (pw.Context context) {
          // Flatten attendances but ensure sorting
          final sorted = List<Attendance>.from(attendances);
          sorted.sort((a, b) => b.checkIn.compareTo(a.checkIn));

          return [
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellStyle: const pw.TextStyle(fontSize: 9),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(2.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.2),
              },
              data: [
                ['Date', 'Staff Member', 'App Login', 'App Logout', 'Duration', 'Branch'],
                ...sorted.map((a) => [
                  DateFormat('dd/MM/yyyy').format(a.checkIn),
                  a.userName.toUpperCase(),
                  DateFormat('hh:mm:ss a').format(a.checkIn),
                  a.checkOut != null 
                    ? DateFormat('hh:mm:ss a').format(a.checkOut!) 
                    : (DateTime.now().difference(a.checkIn).inHours > 16 ? 'FORGOT LOGOUT' : 'STILL ACTIVE'),
                  '${a.currentTotalHours.toStringAsFixed(2)}h',
                  a.branch,
                ]),
              ],
            ),
          ];
        },
        footer: (pw.Context context) => pw.Column(
          children: [
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Internal Audit Document - Jaffna Vehicle Spot', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  static Future<pw.Document> generateStaffTimeReportPdf(List<Attendance> attendances, String title) async {
    final pdf = pw.Document();

    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(logoImage, height: 40),
                    pw.SizedBox(height: 5),
                    pw.Text('JAFFNA VEHICLE SPOT (PVT) LTD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text('Staff Spending Time Report - $title', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated on:', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (pw.Context context) {
          Map<String, List<Attendance>> grouped = {};
          for (var a in attendances) {
            grouped.putIfAbsent(a.userName, () => []).add(a);
          }

          List<List<String>> summaryData = [
            ['Staff Name', 'Sessions', 'Hours', 'Overtime']
          ];

          for (var entry in grouped.entries) {
            double totalHours = 0;
            double totalOvertime = 0;
            for (var a in entry.value) {
              totalHours += a.currentTotalHours;
              totalOvertime += a.overtimeHours;
            }
            summaryData.add([
              entry.key,
              entry.value.length.toString(),
              '${totalHours.toStringAsFixed(2)} hrs',
              '${totalOvertime.toStringAsFixed(2)} hrs',
            ]);
          }

          return [
            pw.Header(
              level: 1,
              text: 'Staff Performance Summary',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900),
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900, width: 2))),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              data: summaryData,
              border: pw.TableBorder.all(color: PdfColors.grey300),
            ),
            pw.SizedBox(height: 30),
            pw.Header(
              level: 1,
              text: 'Detailed Daily Logs',
              textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900),
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900, width: 2))),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                <String>['Date', 'Staff', 'Check-In', 'Check-Out', 'Status', 'Hrs', 'OT'],
                ...attendances.map((a) => [
                      a.date,
                      a.userName,
                      DateFormat('hh:mm a').format(a.checkIn),
                      a.checkOut != null ? DateFormat('hh:mm a').format(a.checkOut!) : '-- : --',
                      a.status,
                      a.currentTotalHours.toStringAsFixed(1),
                      a.overtimeHours.toStringAsFixed(1),
                    ]),
              ],
              border: pw.TableBorder.all(color: PdfColors.grey300),
            ),
          ];
        },
        footer: (pw.Context context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Jaffna Vehicle Spot (Pvt) Ltd', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  static Future<void> downloadStaffUsageAuditPdf(List<Attendance> attendances, String title) async {
    final pdf = await generateStaffUsageAuditPdf(attendances, title);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'staff_usage_${title.replaceAll(' ', '_')}.pdf');
  }

  static Future<void> downloadStaffTimeReportPdf(List<Attendance> attendances, String title) async {
    final pdf = await generateStaffTimeReportPdf(attendances, title);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'staff_time_report_${title.replaceAll(' ', '_')}.pdf');
  }
}

