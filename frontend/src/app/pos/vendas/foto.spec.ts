import { enderecoFoto } from './foto';
import { API_URL } from './vendas.config';

describe('enderecoFoto', () => {
  it('completa com o endereço do backend só as fotos guardadas nele', () => {
    expect(enderecoFoto('/produtos/imagens/3')).toBe(`${API_URL}/produtos/imagens/3`);
    expect(enderecoFoto('https://loja.com/tenis.jpg')).toBe('https://loja.com/tenis.jpg');
    expect(enderecoFoto(null)).toBeNull();
  });
});
