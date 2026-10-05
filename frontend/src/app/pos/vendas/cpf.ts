/*Funções de CPF usadas no PDV (validação local, antes de consultar o backend)*/

export function somenteNumeros(valor: string): string {
  return (valor ?? '').replace(/\D/g, '');
}

/*Valida os dígitos verificadores do CPF*/
export function validarCpf(valor: string): boolean {
  const cpf = somenteNumeros(valor);
  if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) {
    return false;
  }
  const digito = (tamanho: number) => {
    let soma = 0;
    for (let i = 0; i < tamanho; i++) {
      soma += Number(cpf[i]) * (tamanho + 1 - i);
    }
    const resto = (soma * 10) % 11;
    return resto === 10 ? 0 : resto;
  };
  return digito(9) === Number(cpf[9]) && digito(10) === Number(cpf[10]);
}

/*Formata enquanto digita: 000.000.000-00*/
export function formatarCpf(valor: string): string {
  const cpf = somenteNumeros(valor).slice(0, 11);
  return cpf
    .replace(/^(\d{3})(\d)/, '$1.$2')
    .replace(/^(\d{3})\.(\d{3})(\d)/, '$1.$2.$3')
    .replace(/\.(\d{3})(\d{1,2})$/, '.$1-$2');
}
