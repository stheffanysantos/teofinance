import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, deleteDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'teofinance-rules-test',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

const dono = () => env.authenticatedContext('alice').firestore();
const outro = () => env.authenticatedContext('bob').firestore();
const anonimo = () => env.unauthenticatedContext().firestore();

const parcelamentoValido = {
  id: 'p1',
  remoteId: null,
  transacaoOriginalId: 't1',
  totalOriginal: 300.0,
  numeroParcelas: 3,
  dataPrimeiraParc: '2026-10-10T00:00:00.000',
  updatedAt: '2026-10-10T00:00:00.000',
};

describe('coleções sincronizadas hoje', () => {
  for (const colecao of ['transacoes', 'perfis_banco', 'rendas', 'metas']) {
    test(`${colecao}: dono lê e escreve`, async () => {
      const ref = doc(dono(), `users/alice/${colecao}/x`);
      await assertSucceeds(setDoc(ref, { qualquer: 1 }));
      await assertSucceeds(getDoc(ref));
    });

    test(`${colecao}: outro usuário e anônimo são negados`, async () => {
      await env.withSecurityRulesDisabled(async (ctx) => {
        await setDoc(doc(ctx.firestore(), `users/alice/${colecao}/x`), { qualquer: 1 });
      });
      await assertFails(getDoc(doc(outro(), `users/alice/${colecao}/x`)));
      await assertFails(setDoc(doc(outro(), `users/alice/${colecao}/y`), { a: 1 }));
      await assertFails(getDoc(doc(anonimo(), `users/alice/${colecao}/x`)));
    });
  }
});

describe('parcelamentos', () => {
  const ref = (db) => doc(db, 'users/alice/parcelamentos/p1');

  test('dono cria parcelamento válido', async () => {
    await assertSucceeds(setDoc(ref(dono()), parcelamentoValido));
  });

  test('outro usuário não lê nem escreve', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(ref(ctx.firestore()), parcelamentoValido);
    });
    await assertFails(getDoc(ref(outro())));
    await assertFails(setDoc(ref(outro()), parcelamentoValido));
    await assertFails(deleteDoc(ref(outro())));
  });

  test('rejeita número de parcelas fora de 2..12', async () => {
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, numeroParcelas: 1 }));
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, numeroParcelas: 13 }));
  });

  test('rejeita total zero, negativo ou não numérico', async () => {
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, totalOriginal: 0 }));
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, totalOriginal: -10 }));
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, totalOriginal: '300' }));
  });

  test('rejeita campo extra e campo obrigatório ausente', async () => {
    await assertFails(setDoc(ref(dono()), { ...parcelamentoValido, userId: 'bob' }));
    const { transacaoOriginalId, ...semCampo } = parcelamentoValido;
    await assertFails(setDoc(ref(dono()), semCampo));
  });

  test('dono apaga o próprio parcelamento', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(ref(ctx.firestore()), parcelamentoValido);
    });
    await assertSucceeds(deleteDoc(ref(dono())));
  });
});

describe('fora do Firestore por privacidade', () => {
  for (const caminho of [
    'users/alice/extrato_linhas/l1',
    'users/alice/reconciliation_matches/m1',
    'extrato_linhas/l1',
    'parcelamentos/p1',
  ]) {
    test(`${caminho}: negado até para o dono`, async () => {
      await assertFails(setDoc(doc(dono(), caminho), { a: 1 }));
      await assertFails(getDoc(doc(dono(), caminho)));
    });
  }
});
