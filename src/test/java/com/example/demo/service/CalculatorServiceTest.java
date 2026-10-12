package com.example.demo.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class CalculatorServiceTest {

    private final CalculatorService calculatorService = new CalculatorService();

    @Test
    @DisplayName("Kiểm tra phép cộng hai số nguyên (Gradle Test Xanh)")
    void testAdd() {
        int result = calculatorService.add(10, 20);
        assertEquals(30, result, "10 + 20 phải bằng 30");
    }

    @Test
    @DisplayName("Kiểm tra phép nhân hai số nguyên (Gradle Test Xanh)")
    void testMultiply() {
        int result = calculatorService.multiply(5, 6);
        assertEquals(30, result, "5 * 6 phải bằng 30");
    }
}
