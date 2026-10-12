package com.voxa.backend.vendas;

import com.voxa.backend.model.Cliente;
import com.voxa.backend.model.Funcionario;
import com.voxa.backend.model.Produto;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.repository.ClienteRepository;
import com.voxa.backend.repository.FuncionarioRepository;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;

/*
 * Sobe a aplicação inteira com banco H2 e cria os dados de teste.
 * @Transactional desfaz tudo ao final de cada teste.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
abstract class BaseApiTest {

    @Autowired
    protected MockMvc mvc;

    @Autowired
    protected EntityManager em;

    @Autowired
    protected FuncionarioRepository funcionarioRepository;

    @Autowired
    protected ProdutoVariacaoRepository variacaoRepository;

    @Autowired
    protected ClienteRepository clienteRepository;

    protected ProdutoVariacao tenis42;
    protected ProdutoVariacao camisetaM;
    protected Cliente alex;

    @BeforeEach
    void criarDados() {
        funcionario("0001", "Carlos Eduardo Silva", "Vendedor", "Trabalhando", null);
        funcionario("0003", "João Pereira", "Gerente", "Trabalhando", new BigDecimal("1.50"));
        funcionario("0004", "Ana Lima", "Vendedora", "Afastado", null);

        Produto tenis = produto("12345", "Tênis Nike Zoom Fly", "Nike");
        Produto camiseta = produto("20010", "Camiseta Básica Algodão", "VOXA");
        tenis42 = variacao(tenis, "12345142", "42", "Preto", "349.90");
        camisetaM = variacao(camiseta, "20010001", "M", "Branca", "59.90");

        alex = new Cliente();
        alex.setCpf("32970069865");
        alex.setNome("ALEX CAMARGO");
        alex.setSaldoCashback(new BigDecimal("25.50"));
        clienteRepository.save(alex);
    }

    private void funcionario(String prontuario, String nome, String funcao, String situacao, BigDecimal comissao) {
        Funcionario f = new Funcionario();
        f.setProntuario(prontuario);
        f.setNome(nome);
        f.setCpf("12345678900");
        f.setRg("123456789");
        f.setDataNascimento(LocalDate.of(1990, 5, 15));
        f.setFuncao(funcao);
        f.setDataAdmissao(LocalDate.of(2026, 3, 10));
        f.setSituacao(situacao);
        f.setPercentualComissao(comissao);
        funcionarioRepository.save(f);
    }

    private Produto produto(String referencia, String nome, String marca) {
        Produto p = new Produto();
        p.setReferencia(referencia);
        p.setNome(nome);
        p.setMarca(marca);
        em.persist(p);
        return p;
    }

    private ProdutoVariacao variacao(Produto produto, String codigo, String tamanho, String cor, String preco) {
        ProdutoVariacao v = new ProdutoVariacao();
        v.setProduto(produto);
        v.setCodigoBarras(codigo);
        v.setTamanho(tamanho);
        v.setCor(cor);
        v.setPreco(new BigDecimal(preco));
        return variacaoRepository.save(v);
    }
}
