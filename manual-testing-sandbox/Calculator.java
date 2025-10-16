import java.util.ArrayList;
import java.util.List;

/**
 * Une calculatrice avec support du pattern Builder/Fluent API.
 * Permet d'enchaîner les opérations mathématiques et de garder l'historique.
 */
public class Calculator {
    private double result;
    private final List<String> history;

    /**
     * Constructeur qui initialise la calculatrice avec result = 0
     */
    public Calculator() {
        this.result = 0;
        this.history = new ArrayList<>();
        this.history.add("Initialized: 0");
    }

    /**
     * Ajoute un nombre au résultat
     * @param number le nombre à ajouter
     * @return this pour permettre l'enchaînement
     */
    public Calculator add(double number) {
        result += number;
        history.add("ADD " + number + " -> " + result);
        return this;
    }

    /**
     * Soustrait un nombre du résultat
     * @param number le nombre à soustraire
     * @return this pour permettre l'enchaînement
     */
    public Calculator subtract(double number) {
        result -= number;
        history.add("SUBTRACT " + number + " -> " + result);
        return this;
    }

    /**
     * Multiplie le résultat par un nombre
     * @param number le nombre multiplicateur
     * @return this pour permettre l'enchaînement
     */
    public Calculator multiply(double number) {
        if (number == 0) {
            result = 0;
            history.add("MULTIPLY by 0 -> 0");
        } else {
            result *= number;
            history.add("MULTIPLY by " + number + " -> " + result);
        }
        return this;
    }

    /**
     * Divise le résultat par un nombre
     * @param number le diviseur
     * @return this pour permettre l'enchaînement
     * @throws IllegalArgumentException si le diviseur est 0
     */
    public Calculator divide(double number) {
        if (number == 0) {
            throw new IllegalArgumentException("❌ Erreur: Division par zéro impossible!");
        }
        result /= number;
        history.add("DIVIDE by " + number + " -> " + result);
        return this;
    }

    /**
     * Retourne le résultat courant
     * @return la valeur du résultat
     */
    public double getResult() {
        return result;
    }

    /**
     * Réinitialise la calculatrice à 0 et efface l'historique
     * @return this pour permettre l'enchaînement
     */
    public Calculator reset() {
        result = 0;
        history.clear();
        history.add("Initialized: 0");
        return this;
    }

    /**
     * Affiche l'historique de toutes les opérations
     */
    public void showHistory() {
        System.out.println("\n📋 Historique des opérations:");
        for (int i = 0; i < history.size(); i++) {
            System.out.println("  " + (i + 1) + ". " + history.get(i));
        }
    }

    /**
     * Retourne une représentation textuelle de la calculatrice
     * @return string représentant le résultat
     */
    @Override
    public String toString() {
        return "Résultat: " + result;
    }

    public static void main(String[] args) {
        System.out.println("🧮 Tests de la Calculatrice Améliorée\n");

        // Test 1: Opérations simples
        System.out.println("Test 1: Opérations de base");
        Calculator calc = new Calculator();
        calc.add(10).subtract(5).multiply(2);
        System.out.println("✓ " + calc + " (attendu: 10)");
        calc.showHistory();

        // Test 2: Division
        System.out.println("\n\nTest 2: Division");
        Calculator calc2 = new Calculator();
        calc2.add(100).divide(4);
        System.out.println("✓ " + calc2 + " (attendu: 25)");
        calc2.showHistory();

        // Test 3: Chaînage complexe
        System.out.println("\n\nTest 3: Chaînage complexe");
        Calculator calc3 = new Calculator();
        calc3.add(50).multiply(2).subtract(30).divide(2).add(5);
        System.out.println("✓ " + calc3 + " (attendu: 40)");
        calc3.showHistory();

        // Test 4: Reset
        System.out.println("\n\nTest 4: Reset");
        calc3.reset().add(15);
        System.out.println("✓ " + calc3 + " (attendu: 15)");
        calc3.showHistory();

        // Test 5: Gestion d'erreur - Division par zéro
        System.out.println("\n\nTest 5: Gestion d'erreur (division par zéro)");
        try {
            Calculator calc4 = new Calculator();
            calc4.add(10).divide(0);
        } catch (IllegalArgumentException e) {
            System.out.println("✓ Exception capturée: " + e.getMessage());
        }
    }
}
