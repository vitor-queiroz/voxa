package com.voxa.backend.service;

import com.voxa.backend.dto.FormaPagamentoDto;
import com.voxa.backend.repository.FormaPagamentoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FormaPagamentoService {

    private final FormaPagamentoRepository formaPagamentoRepository;

    public FormaPagamentoService(FormaPagamentoRepository formaPagamentoRepository) {
        this.formaPagamentoRepository = formaPagamentoRepository;
    }

    public List<FormaPagamentoDto> listar() {
        return formaPagamentoRepository.findAll().stream().map(FormaPagamentoDto::de).toList();
    }
}
