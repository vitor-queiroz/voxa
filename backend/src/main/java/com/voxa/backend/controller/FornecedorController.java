
package com.voxa.backend.controller;

import com.voxa.backend.model.Fornecedor;
import com.voxa.backend.repository.FornecedorRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController //indica que a classe disponibiliza endpoints HTTP.
@RequestMapping("/api/fornecedores") //define o endereço-base da API.
@CrossOrigin(origins = "http://localhost:4200") //permite que o Angular, rodando localmente na porta 4200, faça requisições ao endpoint.
public class FornecedorController {

    private final FornecedorRepository fornecedorRepository;

    public FornecedorController(FornecedorRepository fornecedorRepository) {
        this.fornecedorRepository = fornecedorRepository;
    }


    @GetMapping //permite consultar os fornecedores por meio de uma requisição GET.
    public List<Fornecedor> listarTodos() {
        return fornecedorRepository.findAll(); //fornecedorRep... = consulta os registros da tabela fornecedor no Aiven.
        }


    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Fornecedor cadastrar(@RequestBody Fornecedor fornecedor) {

        if (fornecedor.getCnpj() == null
                || fornecedor.getCnpj().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "O CNPJ é obrigatório."
            );
        }

        String cnpj = fornecedor.getCnpj().replaceAll("\\D", "");

        if (cnpj.length() != 14) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "O CNPJ deve conter 14 dígitos."
            );
        }

        if (fornecedorRepository.findByCnpj(cnpj).isPresent()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Já existe um fornecedor com esse CNPJ."
            );
        }

        fornecedor.setCnpj(cnpj);

        if (fornecedor.getRazaoSocial() == null
                || fornecedor.getRazaoSocial().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "A razão social é obrigatória."
            );
        }

        return fornecedorRepository.save(fornecedor);
    }
}
