#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Calcolatore di Ricarico e Margine
Markup and Margin Calculator for Windows

Questo programma calcola il ricarico (markup) e il margine (margin)
partendo dal prezzo di partenza e dal prezzo di arrivo.

This program calculates markup and margin based on starting and arrival prices.
"""

def calculate_markup_and_margin(starting_price: float, arrival_price: float) -> dict:
    """
    Calcola ricarico e margine
    
    Args:
        starting_price (float): Prezzo di partenza (costo)
        arrival_price (float): Prezzo di arrivo (vendita)
    
    Returns:
        dict: Dizionario con le seguenti chiavi:
            - markup_absolute (float): Valore assoluto del ricarico
            - markup_percentage (float): Percentuale di ricarico
            - margin_absolute (float): Valore assoluto del margine
            - margin_percentage (float): Percentuale di margine
    """
    # Valore assoluto del ricarico e margine
    absolute_markup = arrival_price - starting_price
    absolute_margin = arrival_price - starting_price
    
    # Percentuale di ricarico: ((Prezzo Vendita - Prezzo Costo) / Prezzo Costo) * 100
    markup_percentage = (absolute_markup / starting_price) * 100 if starting_price != 0 else 0
    
    # Percentuale di margine: ((Prezzo Vendita - Prezzo Costo) / Prezzo Vendita) * 100
    margin_percentage = (absolute_margin / arrival_price) * 100 if arrival_price != 0 else 0
    
    return {
        'markup_absolute': absolute_markup,
        'markup_percentage': markup_percentage,
        'margin_absolute': absolute_margin,
        'margin_percentage': margin_percentage
    }

def format_currency(value):
    """Formatta un valore come valuta"""
    return f"€ {value:.2f}"

def format_percentage(value):
    """Formatta un valore come percentuale"""
    return f"{value:.2f}%"

def print_separator():
    """Stampa una linea separatrice"""
    print("=" * 60)

def main():
    """Funzione principale del programma"""
    print_separator()
    print("       CALCOLATORE DI RICARICO E MARGINE")
    print("         MARKUP AND MARGIN CALCULATOR")
    print_separator()
    print()
    
    while True:
        try:
            # Input prezzo di partenza
            print("Inserisci il prezzo di partenza (costo):")
            print("Enter starting price (cost):")
            starting_price_input = input("€ ")
            starting_price = float(starting_price_input.replace(',', '.'))
            
            if starting_price < 0:
                print("⚠️  Errore: Il prezzo di partenza non può essere negativo.")
                print("⚠️  Error: Starting price cannot be negative.")
                print()
                continue
            
            # Input prezzo di arrivo
            print("\nInserisci il prezzo di arrivo (vendita):")
            print("Enter arrival price (selling):")
            arrival_price_input = input("€ ")
            arrival_price = float(arrival_price_input.replace(',', '.'))
            
            if arrival_price < 0:
                print("⚠️  Errore: Il prezzo di arrivo non può essere negativo.")
                print("⚠️  Error: Arrival price cannot be negative.")
                print()
                continue
            
            # Calcola ricarico e margine
            results = calculate_markup_and_margin(starting_price, arrival_price)
            
            # Mostra i risultati
            print()
            print_separator()
            print("                    RISULTATI / RESULTS")
            print_separator()
            print()
            
            print(f"Prezzo di partenza (costo):    {format_currency(starting_price)}")
            print(f"Starting price (cost):         {format_currency(starting_price)}")
            print()
            
            print(f"Prezzo di arrivo (vendita):    {format_currency(arrival_price)}")
            print(f"Arrival price (selling):       {format_currency(arrival_price)}")
            print()
            
            print_separator()
            print("RICARICO / MARKUP:")
            print_separator()
            print(f"  Valore assoluto / Absolute:  {format_currency(results['markup_absolute'])}")
            print(f"  Percentuale / Percentage:    {format_percentage(results['markup_percentage'])}")
            print()
            
            print_separator()
            print("MARGINE / MARGIN:")
            print_separator()
            print(f"  Valore assoluto / Absolute:  {format_currency(results['margin_absolute'])}")
            print(f"  Percentuale / Percentage:    {format_percentage(results['margin_percentage'])}")
            print()
            
            print_separator()
            print()
            
            # Spiegazione formule
            print("📝 Formule / Formulas:")
            print()
            print("   Ricarico % = ((Prezzo Vendita - Prezzo Costo) / Prezzo Costo) × 100")
            print("   Markup % = ((Selling Price - Cost Price) / Cost Price) × 100")
            print()
            print("   Margine % = ((Prezzo Vendita - Prezzo Costo) / Prezzo Vendita) × 100")
            print("   Margin % = ((Selling Price - Cost Price) / Selling Price) × 100")
            print()
            print_separator()
            
            # Chiedi se continuare
            print("\nVuoi effettuare un altro calcolo? (s/n)")
            print("Do you want to perform another calculation? (y/n)")
            choice = input("> ").strip().lower()
            
            if choice not in ['s', 'y', 'si', 'yes']:
                print("\nGrazie per aver utilizzato il calcolatore!")
                print("Thank you for using the calculator!")
                print()
                break
            
            print("\n" * 2)
            
        except ValueError:
            print("\n⚠️  Errore: Inserisci un numero valido.")
            print("⚠️  Error: Please enter a valid number.")
            print()
        except KeyboardInterrupt:
            print("\n\nProgramma interrotto dall'utente.")
            print("Program interrupted by user.")
            print()
            break
        except Exception as e:
            print(f"\n⚠️  Errore imprevisto: {e}")
            print(f"⚠️  Unexpected error: {e}")
            print()

if __name__ == "__main__":
    main()
