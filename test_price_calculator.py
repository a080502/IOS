#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test del Calcolatore di Ricarico e Margine
Test for Markup and Margin Calculator
"""

import sys
sys.path.insert(0, '/home/runner/work/IOS/IOS')

from price_calculator import calculate_markup_and_margin, format_currency, format_percentage

def test_basic_calculation():
    """Test calcolo base: costo 100, vendita 150"""
    result = calculate_markup_and_margin(100, 150)
    
    assert result['markup_absolute'] == 50, f"Expected 50, got {result['markup_absolute']}"
    assert result['markup_percentage'] == 50.0, f"Expected 50.0%, got {result['markup_percentage']}%"
    assert result['margin_absolute'] == 50, f"Expected 50, got {result['margin_absolute']}"
    assert abs(result['margin_percentage'] - 33.33) < 0.01, f"Expected ~33.33%, got {result['margin_percentage']}%"
    
    print("✅ Test calcolo base: PASSED")

def test_double_markup():
    """Test raddoppio: costo 50, vendita 100 (markup 100%)"""
    result = calculate_markup_and_margin(50, 100)
    
    assert result['markup_absolute'] == 50, f"Expected 50, got {result['markup_absolute']}"
    assert result['markup_percentage'] == 100.0, f"Expected 100.0%, got {result['markup_percentage']}%"
    assert result['margin_absolute'] == 50, f"Expected 50, got {result['margin_absolute']}"
    assert result['margin_percentage'] == 50.0, f"Expected 50.0%, got {result['margin_percentage']}%"
    
    print("✅ Test raddoppio: PASSED")

def test_decimal_values():
    """Test valori decimali: costo 99.50, vendita 149.99"""
    result = calculate_markup_and_margin(99.50, 149.99)
    
    assert abs(result['markup_absolute'] - 50.49) < 0.01, f"Expected ~50.49, got {result['markup_absolute']}"
    assert abs(result['markup_percentage'] - 50.74) < 0.01, f"Expected ~50.74%, got {result['markup_percentage']}%"
    assert abs(result['margin_absolute'] - 50.49) < 0.01, f"Expected ~50.49, got {result['margin_absolute']}"
    assert abs(result['margin_percentage'] - 33.66) < 0.01, f"Expected ~33.66%, got {result['margin_percentage']}%"
    
    print("✅ Test valori decimali: PASSED")

def test_same_price():
    """Test stesso prezzo: costo 100, vendita 100 (no profit)"""
    result = calculate_markup_and_margin(100, 100)
    
    assert result['markup_absolute'] == 0, f"Expected 0, got {result['markup_absolute']}"
    assert result['markup_percentage'] == 0.0, f"Expected 0.0%, got {result['markup_percentage']}%"
    assert result['margin_absolute'] == 0, f"Expected 0, got {result['margin_absolute']}"
    assert result['margin_percentage'] == 0.0, f"Expected 0.0%, got {result['margin_percentage']}%"
    
    print("✅ Test stesso prezzo: PASSED")

def test_loss():
    """Test perdita: costo 150, vendita 100 (loss)"""
    result = calculate_markup_and_margin(150, 100)
    
    assert result['markup_absolute'] == -50, f"Expected -50, got {result['markup_absolute']}"
    assert abs(result['markup_percentage'] - (-33.33)) < 0.01, f"Expected ~-33.33%, got {result['markup_percentage']}%"
    assert result['margin_absolute'] == -50, f"Expected -50, got {result['margin_absolute']}"
    assert result['margin_percentage'] == -50.0, f"Expected -50.0%, got {result['margin_percentage']}%"
    
    print("✅ Test perdita: PASSED")

def test_formatting():
    """Test formattazione valori"""
    assert format_currency(100.5) == "€ 100.50", "Currency formatting failed"
    assert format_currency(99.99) == "€ 99.99", "Currency formatting failed"
    assert format_percentage(50.5) == "50.50%", "Percentage formatting failed"
    assert format_percentage(33.33) == "33.33%", "Percentage formatting failed"
    
    print("✅ Test formattazione: PASSED")

def run_all_tests():
    """Esegue tutti i test"""
    print()
    print("=" * 60)
    print("    TEST CALCOLATORE DI RICARICO E MARGINE")
    print("    MARKUP AND MARGIN CALCULATOR TESTS")
    print("=" * 60)
    print()
    
    try:
        test_basic_calculation()
        test_double_markup()
        test_decimal_values()
        test_same_price()
        test_loss()
        test_formatting()
        
        print()
        print("=" * 60)
        print("    ✅ TUTTI I TEST SUPERATI / ALL TESTS PASSED")
        print("=" * 60)
        print()
        return True
    except AssertionError as e:
        print()
        print("=" * 60)
        print(f"    ❌ TEST FALLITO / TEST FAILED")
        print(f"    Errore: {e}")
        print("=" * 60)
        print()
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
