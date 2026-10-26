package com.voxa.backend.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/*Valores em dinheiro sempre com 2 casas decimais, arredondando metade para cima*/
public final class Dinheiro {

    public static final BigDecimal ZERO = BigDecimal.ZERO.setScale(2);
    private static final BigDecimal CEM = new BigDecimal("100");

    private Dinheiro() {
    }

    public static BigDecimal arredondar(BigDecimal valor) {
        return valor.setScale(2, RoundingMode.HALF_UP);
    }

    /*valor × percentual / 100, arredondado*/
    public static BigDecimal percentualDe(BigDecimal valor, BigDecimal percentual) {
        return arredondar(valor.multiply(percentual).divide(CEM, 4, RoundingMode.HALF_UP));
    }

    public static boolean positivo(BigDecimal valor) {
        return valor != null && valor.signum() > 0;
    }
}
