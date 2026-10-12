package com.voxa.backend.vendas;

import com.voxa.backend.util.Cpf;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CpfTest {

    @Test
    void validaOsDigitosVerificadores() {
        assertThat(Cpf.valido("329.700.698-65")).isTrue();
        assertThat(Cpf.valido("32970069864")).isFalse();
        assertThat(Cpf.valido("11111111111")).isFalse();
        assertThat(Cpf.valido("123")).isFalse();
        assertThat(Cpf.valido(null)).isFalse();
    }
}
