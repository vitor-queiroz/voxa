import { API_URL } from './vendas.config';

/*Tipos de foto aceitos no PDV (o backend confere de novo pelo conteúdo do arquivo)*/
export const TIPOS_FOTO = ['image/jpeg', 'image/png', 'image/webp'];

/*Tamanho máximo do arquivo escolhido; antes de enviar ele é reduzido para bem menos que isso*/
export const TAMANHO_MAXIMO_FOTO = 20 * 1024 * 1024;

/*Endereço da foto para o <img>: as fotos guardadas no backend vêm como "/produtos/imagens/1"*/
export function enderecoFoto(url: string | null | undefined): string | null {
  if (!url) {
    return null;
  }
  return url.startsWith('/') ? `${API_URL}${url}` : url;
}

/*
 * Reduz a foto (lado maior com até 1000 px, em JPG) para o envio ser rápido
 * e caber no limite de 1 MB do backend, mesmo se for foto tirada pelo celular.
 */
export async function reduzirFoto(arquivo: Blob, ladoMaximo = 1000, qualidade = 0.85): Promise<Blob> {
  const imagem = await createImageBitmap(arquivo);
  const escala = Math.min(1, ladoMaximo / Math.max(imagem.width, imagem.height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.round(imagem.width * escala);
  canvas.height = Math.round(imagem.height * escala);

  const contexto = canvas.getContext('2d');
  if (!contexto) {
    throw new Error('Não foi possível preparar a imagem.');
  }
  contexto.fillStyle = '#ffffff'; /*PNG com fundo transparente fica com fundo branco*/
  contexto.fillRect(0, 0, canvas.width, canvas.height);
  contexto.drawImage(imagem, 0, 0, canvas.width, canvas.height);
  imagem.close();

  return new Promise((resolve, reject) =>
    canvas.toBlob(
      (foto) => (foto ? resolve(foto) : reject(new Error('Não foi possível preparar a imagem.'))),
      'image/jpeg',
      qualidade,
    ),
  );
}
