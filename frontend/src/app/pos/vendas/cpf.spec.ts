import { formatarCpf, validarCpf } from './cpf';

describe('cpf', () => {
  it('deve validar os dígitos verificadores', () => {
    expect(validarCpf('329.700.698-65')).toBe(true);
    expect(validarCpf('32970069864')).toBe(false);
    expect(validarCpf('11111111111')).toBe(false);
    expect(validarCpf('123')).toBe(false);
  });

  it('deve formatar enquanto digita', () => {
    expect(formatarCpf('329')).toBe('329');
    expect(formatarCpf('3297006')).toBe('329.700.6');
    expect(formatarCpf('32970069865')).toBe('329.700.698-65');
  });
});
