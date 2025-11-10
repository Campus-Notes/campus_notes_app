import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  int _currentPageIndex = 0;
  bool _isCompleted = false;
  
  int get currentPageIndex => _currentPageIndex;
  bool get isCompleted => _isCompleted;
  bool get isLastPage => _currentPageIndex == 2; // Assuming 3 onboarding pages
  
  void nextPage() {
    if (_currentPageIndex < 2) {
      _currentPageIndex++;
      notifyListeners();
    } else {
      _isCompleted = true;
      notifyListeners();
    }
  }
  
  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }
  
  void goToPage(int index) {
    if (index >= 0 && index <= 2) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }
  
  void completeOnboarding() {
    _isCompleted = true;
    notifyListeners();
  }
  
  void resetOnboarding() {
    _currentPageIndex = 0;
    _isCompleted = false;
    notifyListeners();
  }
}