# 🤝 Guia de Contribuição

Obrigado por considerar contribuir para o Laravel Docker Mono! 

## 📋 Como Contribuir

### 1. Fork e Clone

```bash
# Fork o repositório no GitHub
# Clone seu fork
git clone https://github.com/seu-usuario/laravel-docker-mono.git
cd laravel-docker-mono
```

### 2. Crie uma Branch

```bash
# Use o comando make
make git-branch-create
# Digite: feature/sua-feature

# Ou manualmente
git checkout -b feature/sua-feature
```

### 3. Faça suas Alterações

Certifique-se de:
- ✅ Seguir os padrões de código do projeto
- ✅ Adicionar testes se necessário
- ✅ Atualizar documentação se aplicável
- ✅ Manter compatibilidade com estrutura existente

### 4. Teste suas Alterações

```bash
# Execute os testes
make test

# Verifique qualidade do código
make quality-check

# Verifique se nada quebrou
make verify-environment
```

### 5. Commit e Push

```bash
# Use o workflow rápido
make git-quick-push
```

### 6. Abra um Pull Request

1. Vá para o repositório original no GitHub
2. Clique em "Pull Request"
3. Selecione sua branch
4. Descreva suas alterações
5. Aguarde review

## 📝 Padrões de Commit

Use mensagens claras e descritivas:

```
feat: adiciona comando make para deploy automático
fix: corrige problema com backup do PostgreSQL
docs: atualiza README com novos comandos
refactor: reorganiza módulo de testes
chore: atualiza dependências do Composer
```

## ✅ Checklist de Contribuição

- [ ] Código testado localmente
- [ ] Testes passando (`make test`)
- [ ] Qualidade verificada (`make quality-check`)
- [ ] Documentação atualizada
- [ ] Comandos Make documentados

---

**Dúvidas?** Abra uma Issue ou inicie uma Discussion.
