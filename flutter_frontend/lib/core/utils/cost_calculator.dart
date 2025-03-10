
class CostCalculator {
  static double calculateDiscountedCost(double originalCost, String? segment) {
    switch (segment) {
      case 'A': return originalCost * 0.90;
      case 'B': return originalCost * 0.94;
      case 'C': return originalCost * 0.97;
      default: return originalCost;
    }
  }

}