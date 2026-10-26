package com.voxa.backend.repository;

import com.voxa.backend.model.StatusVenda;
import com.voxa.backend.model.Venda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/*JpaSpecificationExecutor permite montar os filtros opcionais do GET /vendas*/
public interface VendaRepository extends JpaRepository<Venda, Long>, JpaSpecificationExecutor<Venda> {

    /*Totais por prontuário (quantidade de vendas e valor vendido) no período*/
    @Query("""
            select v.vendedor.prontuario as prontuario,
                   count(v) as quantidadeVendas,
                   sum(v.total) as totalVendido
            from Venda v
            where v.status = :status and v.data >= :inicio and v.data < :fim
            group by v.vendedor.prontuario
            """)
    List<TotaisPorVendedor> totaisPorVendedor(@Param("status") StatusVenda status,
                                              @Param("inicio") LocalDateTime inicio,
                                              @Param("fim") LocalDateTime fim);

    /*Peças vendidas por prontuário no período*/
    @Query("""
            select v.vendedor.prontuario as prontuario, sum(i.quantidade) as pecas
            from ItemVenda i join i.venda v
            where v.status = :status and v.data >= :inicio and v.data < :fim
            group by v.vendedor.prontuario
            """)
    List<PecasPorVendedor> pecasPorVendedor(@Param("status") StatusVenda status,
                                            @Param("inicio") LocalDateTime inicio,
                                            @Param("fim") LocalDateTime fim);

    interface TotaisPorVendedor {
        String getProntuario();

        Long getQuantidadeVendas();

        BigDecimal getTotalVendido();
    }

    interface PecasPorVendedor {
        String getProntuario();

        Long getPecas();
    }
}
