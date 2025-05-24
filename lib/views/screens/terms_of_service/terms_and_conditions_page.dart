import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Check if the user has scrolled to the bottom
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        setState(() {
          _isAtBottom = true;
        });
      } else {
        setState(() {
          _isAtBottom = false;
        });
      }
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
          leadingWidget: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFFB4914B),
              )),
          actionWidgets: Row(
            children: [
              Text(
                "Terms and Conditions",
                style: TextStyle(
                  color: const Color(0xFFB4914B), // Gold color
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Color(0xFFB4914B)), // Gold color
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      //   title:  Text(
      //     "Terms and Conditions",
      //     style: TextStyle(
      //       color: const Color(0xFFB4914B), // Gold color
      //       fontSize: 20.px,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'), // Default image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Terms and Conditions Content
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Terms and Conditions",
                //   style: TextStyle(
                //     color: Color(0xFFB4914B), // Gold color
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                SizedBox(height: 2.h),
                const Text(
                  "1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum vestibulum.\n\n"
                  "2. Curabitur sit amet massa nec ligula scelerisque sollicitudin. Morbi feugiat, neque a facilisis consectetur, "
                  "felis augue gravida nunc, nec ultrices sem sapien in purus.\n\n"
                  "3. Proin nec eros non enim ultrices tincidunt. Nulla facilisi. Phasellus tristique lorem nec purus laoreet "
                  "mattis.\n\n"
                  "4. Sed dapibus, nisl vel varius fringilla, risus magna pharetra ligula, in ultrices ligula nisi id purus.\n\n"
                  "5. Quisque ultricies nunc sit amet libero dapibus, et ullamcorper libero accumsan.",
                  style: TextStyle(
                    color: Color(0xFFB4914B), // Gold color
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6.h),
                const Text(
                  "By accepting these terms and conditions, you agree to abide by the rules outlined above.",
                  style: TextStyle(
                    color: Color(0xFFB4914B), // Gold color
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20.h), // Add extra space for bottom buttons
              ],
            ),
          ),
          // Floating Buttons
          Positioned(
            bottom: 16,
            left: MediaQuery.of(context).size.width / 2 - 100, // Center align
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 0, 0, 0), // Black background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: const Color(0xFFB4914B), // Gold color
                        width: 0.7.w, // Border width
                      ),
                    ),
                  ),
                  onPressed: _isAtBottom ? _scrollToTop : _scrollToBottom,
                  child: Text(
                    _isAtBottom ? "Scroll to Top" : "Accept and Continue",
                    style: const TextStyle(
                        color: Color(0xFFB4914B),
                        fontWeight: FontWeight.w600), // Gold text
                  ),
                ),
                const SizedBox(height: 16),
                if (_isAtBottom)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4914B), // Gold color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Accepted Terms and Conditions',
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Color(0xFFB4914B), // Gold color
                        ),
                      );
                    },
                    child: const Text(
                      "Accept and Continue",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
