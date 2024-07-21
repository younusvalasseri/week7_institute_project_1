import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/account_transaction.dart';
import '../models/student.dart';
import '../models/employee.dart';
import 'student_details_income.dart';
import '../custom_date_range_picker.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  // ignore: library_private_types_in_public_api
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late Student _student;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  double _calculateCollectedFee() {
    final transactionsBox = Hive.box<AccountTransaction>('transactions');
    double collectedFee = transactionsBox.values
        .where((transaction) =>
            transaction.mainCategory == 'Student Fee' &&
            transaction.studentId == widget.student.admNumber)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    return collectedFee;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _student.profilePicture = image.path;
      });
      await _student.save();
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (!mounted) return; // Ensure the context is still valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectedFee = _calculateCollectedFee();
    final balance = (widget.student.courseFee ?? 0) - collectedFee;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_student.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _student.profilePicture != null
                    ? FileImage(File(_student.profilePicture!))
                    : null,
                child: _student.profilePicture == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _student.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Admission Number', _student.admNumber, 'Name',
                _student.name, 'Address', _student.address),
            _buildInfoCard(
                'Course', _student.course, 'Batch', _student.batch, '', ''),
            _buildPhoneInfoCard(
                'Father\'s Phone',
                _student.fatherPhone,
                'Mother\'s Phone',
                _student.motherPhone,
                'Student\'s Phone',
                _student.studentPhone),
            _buildClassTeacherDropdown(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsIncomeScreen(
                      student: _student,
                    ),
                  ),
                );
              },
              child: _buildInfoCard(
                'Course Fee',
                '₹ ${_student.courseFee?.toStringAsFixed(2)}',
                'Collected Fee',
                '₹ ${collectedFee.toStringAsFixed(2)}',
                'Balance Fee',
                '₹ ${balance.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCertificateDialog(context),
              child: const Text('Print Certificate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label1, String value1, String label2,
      String value2, String label3, String value3) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label1.isNotEmpty) _buildInfoTile(label1, value1),
            if (label2.isNotEmpty) _buildInfoTile(label2, value2),
            if (label3.isNotEmpty) _buildInfoTile(label3, value3),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInfoCard(String label1, String value1, String label2,
      String value2, String label3, String value3) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label1.isNotEmpty) _buildPhoneInfoTile(label1, value1),
            if (label2.isNotEmpty) _buildPhoneInfoTile(label2, value2),
            if (label3.isNotEmpty) _buildPhoneInfoTile(label3, value3),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    Color valueColor = Colors.black;
    if (label.contains('Collected Fee')) {
      valueColor = Colors.green;
    } else if (label.contains('Balance Fee')) {
      valueColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInfoTile(String label, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _makePhoneCall(phone),
              child: Text(
                phone,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTeacherDropdown() {
    final employeeBox = Hive.box<Employee>('employees');
    final facultyList = employeeBox.values
        .where((employee) => employee.position == 'Faculty')
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _student.classTeacher,
        decoration: const InputDecoration(labelText: 'Class Teacher'),
        items: facultyList.map((employee) {
          return DropdownMenuItem<String>(
            value: employee.empNumber,
            child: Text(employee.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _student.classTeacher = value;
          });
          _student.save();
        },
      ),
    );
  }

  void _showCertificateDialog(BuildContext context) {
    final courseController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final competenciesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Certificate Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                ),
                GestureDetector(
                  onTap: () async {
                    DateTimeRange? picked = await showDialog<DateTimeRange>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDateRangePicker(
                          initialDateRange: DateTimeRange(
                            start: DateTime.now(),
                            end: DateTime.now(),
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      startDateController.text =
                          DateFormat('dd/MMM/yyyy').format(picked.start);
                      endDateController.text =
                          DateFormat('dd/MMM/yyyy').format(picked.end);
                    }
                  },
                  child: AbsorbPointer(
                    child: Column(
                      children: [
                        TextField(
                          controller: startDateController,
                          decoration:
                              const InputDecoration(labelText: 'Start Date'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: endDateController,
                          decoration:
                              const InputDecoration(labelText: 'End Date'),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: competenciesController,
                  decoration: const InputDecoration(labelText: 'Competencies'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Preview'),
              onPressed: () {
                Navigator.of(context).pop();
                _previewCertificate(
                  courseController.text,
                  startDateController.text,
                  endDateController.text,
                  competenciesController.text,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _previewCertificate(String course, String startDate,
      String endDate, String competencies) async {
    final pdf = pw.Document();

    final ByteData bytes = await rootBundle.load('assets/iat_logo.jpg');
    final Uint8List byteList = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(byteList);

    final ByteData bytesNtem = await rootBundle.load('assets/NTEM.png');
    final Uint8List byteListNtem = bytesNtem.buffer.asUint8List();
    final imageNtem = pw.MemoryImage(byteListNtem);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(image, width: 100),
                    pw.Text(
                      'Certificate',
                      style: pw.TextStyle(
                        fontSize: 40,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Image(imageNtem, width: 100),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.Text(
                    'Mr. ${_student.name}',
                    style: const pw.TextStyle(fontSize: 30),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'has successfully completed the training on',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    '$course from $startDate to $endDate',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'During this period he has gone through the following competencies successfully:',
                    style: const pw.TextStyle(fontSize: 15),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    competencies,
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    'Head of the Department',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (!mounted) return;

    // Preview the PDF instead of directly opening print dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Certificate Preview'),
            leading: const BackButton(),
          ),
          body: PdfPreview(
            build: (format) => pdf.save(),
            canChangePageFormat: false, // Disable changing page format
            allowPrinting: true,
            canChangeOrientation: false, // Disable changing orientation
            canDebug: false,
          ),
        ),
      ),
    );
  }
}
