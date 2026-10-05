import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NgForm } from '@angular/forms';

import { CadastroCliente } from './cadastro-cliente';
import { Cliente } from '../../vendas.model';

describe('CadastroCliente', () => {
  let component: CadastroCliente;
  let fixture: ComponentFixture<CadastroCliente>;
  const formValido = { invalid: false } as NgForm;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CadastroCliente]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CadastroCliente);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('cpfInicial', '11144477735');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve trazer o CPF digitado no PDV já formatado', () => {
    expect(component.cpf).toBe('111.444.777-35');
  });

  it('deve recusar CPF inválido', () => {
    component.cpf = '111.444.777-00';
    component.nome = 'Teste';
    component.salvar(formValido);

    expect(component.erro()).toBe('CPF inválido.');
  });

  it('deve salvar e emitir o cliente com id', () => {
    let salvo: Cliente | undefined;
    component.salvo.subscribe((c) => (salvo = c));
    component.nome = 'joana souza';
    component.salvar(formValido);

    expect(salvo?.id).not.toBeNull();
    expect(salvo?.nome).toBe('JOANA SOUZA');
    expect(salvo?.cpf).toBe('11144477735');
  });
});
