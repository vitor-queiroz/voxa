package com.voxa.backend.service;

import com.voxa.backend.dto.FuncionarioResumo;
import com.voxa.backend.dto.ResumoComissao;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.StatusVenda;
import com.voxa.backend.repository.FuncionarioRepository;
import com.voxa.backend.repository.VendaRepository;
import com.voxa.backend.util.Dinheiro;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/*Painel de vendedores: uma linha por funcionário com os totais das vendas FINALIZADAS no período*/
@Service
public class ComissaoService {

    private static final LocalDate INICIO_PADRAO = LocalDate.of(2000, 1, 1);

    private final FuncionarioRepository funcionarioRepository;
    private final VendaRepository vendaRepository;

    public ComissaoService(FuncionarioRepository funcionarioRepository, VendaRepository vendaRepository) {
        this.funcionarioRepository = funcionarioRepository;
        this.vendaRepository = vendaRepository;
    }

    @Transactional(readOnly = true)
    public List<ResumoComissao> resumo(LocalDate de, LocalDate ate) {
        LocalDateTime inicio = (de != null ? de : INICIO_PADRAO).atStartOfDay();
        LocalDateTime fim = (ate != null ? ate : LocalDate.now()).plusDays(1).atStartOfDay();
        if (!inicio.isBefore(fim)) {
            throw new RegraNegocioException("A data inicial deve ser antes da data final.");
        }

        Map<String, VendaRepository.TotaisPorVendedor> totais = vendaRepository
                .totaisPorVendedor(StatusVenda.FINALIZADA, inicio, fim).stream()
                .collect(Collectors.toMap(VendaRepository.TotaisPorVendedor::getProntuario, Function.identity()));
        Map<String, Long> pecas = vendaRepository
                .pecasPorVendedor(StatusVenda.FINALIZADA, inicio, fim).stream()
                .collect(Collectors.toMap(VendaRepository.PecasPorVendedor::getProntuario, VendaRepository.PecasPorVendedor::getPecas));

        return funcionarioRepository.findAllByOrderByNomeAsc().stream().map(funcionario -> {
            VendaRepository.TotaisPorVendedor dele = totais.get(funcionario.getProntuario());
            return new ResumoComissao(
                    FuncionarioResumo.de(funcionario),
                    dele == null ? 0 : dele.getQuantidadeVendas(),
                    pecas.getOrDefault(funcionario.getProntuario(), 0L),
                    dele == null ? Dinheiro.ZERO : Dinheiro.arredondar(dele.getTotalVendido()),
                    dele == null ? Dinheiro.ZERO : Dinheiro.arredondar(dele.getValorComissao()));
        }).toList();
    }
}
