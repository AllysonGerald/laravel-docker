# 🏗️ Arquitetura do Projeto

Este documento descreve a estrutura de arquitetura em camadas utilizada neste projeto Laravel.

## 📋 Visão Geral

O projeto segue uma arquitetura em camadas bem definida, separando responsabilidades e facilitando a manutenção, testabilidade e escalabilidade do código.

```
┌─────────────────────────────────────────────────────┐
│              🌐 HTTP Request (Cliente)              │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          📥 Camada de Transporte (app/Http/)        │
│      Controllers | Middleware | Form Requests       │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│         ⚙️  Camada de Negócio (app/Services/)       │
│          Regras de Negócio | Orquestração          │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│       💾 Camada de Dados (app/Repositories/)        │
│         Acesso a Dados | Query Builder             │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│      🗄️  Camada de Persistência (app/Models/)       │
│              Eloquent ORM | Eloquent                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│                💿 Banco de Dados                     │
│         MySQL | PostgreSQL | MongoDB                │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Pastas

### 🌐 `app/Http/` - Camada de Transporte/Interface

**Função:** Lida com requisições HTTP. Contém Controllers, Middleware e Requests.

**Responsabilidade:** Esta camada **só deve delegar tarefas**. Não deve conter lógica de negócio.

**Exemplo:**

```php
// app/Http/Controllers/UserController.php
class UserController extends Controller
{
    public function __construct(
        private UserService $userService
    ) {}

    public function store(StoreUserRequest $request)
    {
        $user = $this->userService->createUser($request->validated());
        return new UserResource($user);
    }
}
```

**Comandos úteis:**
```bash
make make:controller       # Criar controller
make make:request          # Criar form request
make make:middleware       # Criar middleware
```

---

### ⚙️ `app/Services/` - Camada de Serviço/Negócio

**Função:** Contém as regras de negócio complexas, transações e orquestração de várias operações.

**Responsabilidade:** É chamada pelos Controllers. Coordena operações entre múltiplos Repositories e executa lógica de negócio.

**Exemplo:**

```php
// app/Services/UserService.php
class UserService
{
    public function __construct(
        private UserRepository $userRepository,
        private NotificationService $notificationService
    ) {}

    public function createUser(array $data): User
    {
        DB::beginTransaction();
        try {
            $user = $this->userRepository->create($data);
            $this->notificationService->sendWelcomeEmail($user);
            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

**Comandos úteis:**
```bash
make make-service          # Criar service
```

---

### 💾 `app/Repositories/` - Camada de Repositório/Acesso a Dados

**Função:** Abstrai o acesso a dados. O Service chama o Repository para buscar/salvar Models.

**Responsabilidade:** Isola o código Eloquent e permite trocar a implementação de acesso a dados sem afetar a lógica de negócio.

**Exemplo:**

```php
// app/Repositories/Contracts/UserRepositoryInterface.php
interface UserRepositoryInterface
{
    public function create(array $data): User;
    public function findByEmail(string $email): ?User;
    public function update(User $user, array $data): User;
}

// app/Repositories/UserRepository.php
class UserRepository implements UserRepositoryInterface
{
    public function create(array $data): User
    {
        return User::create($data);
    }

    public function findByEmail(string $email): ?User
    {
        return User::where('email', $email)->first();
    }

    public function update(User $user, array $data): User
    {
        $user->update($data);
        return $user->fresh();
    }
}
```

**Comandos úteis:**
```bash
make make-repository       # Criar repository + interface
```

---

### 🗄️ `app/Models/` - Camada de Modelo/Persistência

**Função:** Classes Eloquent que representam as tabelas do banco de dados.

**Responsabilidade:** Devem ser o mais "burras" possível, focadas em relacionamento e acesso básico. **Não devem conter lógica de negócio.**

**Exemplo:**

```php
// app/Models/User.php
class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];

    protected $hidden = ['password', 'remember_token'];

    // Relacionamentos
    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    // Accessors/Mutators
    protected function password(): Attribute
    {
        return Attribute::make(
            set: fn ($value) => bcrypt($value),
        );
    }
}
```

**Comandos úteis:**
```bash
make make:model            # Criar model
make make:model -m         # Criar model + migration
make make:model -mfsc      # Criar model + migration + factory + seeder + controller
```

---

### 🎯 `app/Actions/` - Ações/Comandos de Uso Único

**Função:** Classes para encapsular uma única ação ou fluxo de trabalho complexo e testável.

**Responsabilidade:** Uma alternativa para simplificar Services muito grandes. Cada Action faz **uma coisa só, mas faz bem**.

**Exemplo:**

```php
// app/Actions/ProcessPaymentAction.php
class ProcessPaymentAction
{
    public function __construct(
        private PaymentGateway $gateway,
        private OrderRepository $orderRepository
    ) {}

    public function execute(Order $order, array $paymentData): Payment
    {
        $payment = $this->gateway->charge(
            amount: $order->total,
            method: $paymentData['method'],
            customer: $order->customer
        );

        $this->orderRepository->markAsPaid($order, $payment);

        return $payment;
    }
}
```

**Comandos úteis:**
```bash
make make-action           # Criar action
```

---

### 🔢 `app/Enums/` - Constantes Tipadas

**Função:** Classes Enum para representar listas fixas de valores (status, tipos, etc).

**Responsabilidade:** Evitar "magic strings" e fornecer type-safety.

**Exemplo:**

```php
// app/Enums/OrderStatus.php
enum OrderStatus: string
{
    case PENDING = 'pending';
    case PAID = 'paid';
    case SHIPPED = 'shipped';
    case DELIVERED = 'delivered';
    case CANCELLED = 'cancelled';

    public function label(): string
    {
        return match($this) {
            self::PENDING => 'Aguardando Pagamento',
            self::PAID => 'Pago',
            self::SHIPPED => 'Enviado',
            self::DELIVERED => 'Entregue',
            self::CANCELLED => 'Cancelado',
        };
    }

    public function color(): string
    {
        return match($this) {
            self::PENDING => 'yellow',
            self::PAID => 'blue',
            self::SHIPPED => 'purple',
            self::DELIVERED => 'green',
            self::CANCELLED => 'red',
        };
    }
}

// Uso:
$order->status = OrderStatus::PAID;
echo $order->status->label(); // "Pago"
```

**Comandos úteis:**
```bash
make make:enum             # Criar enum
```

---

### 👁️ `app/Observers/` - Listeners de Eventos de Model

**Função:** Lógica reativa a mudanças no Model (enviar e-mail após salvar, atualizar cache, etc).

**Responsabilidade:** Executar ações automáticas quando eventos do Model são disparados (creating, created, updating, updated, deleting, deleted).

**Exemplo:**

```php
// app/Observers/UserObserver.php
class UserObserver
{
    public function creating(User $user): void
    {
        $user->uuid = Str::uuid();
    }

    public function created(User $user): void
    {
        // Enviar email de boas-vindas
        Mail::to($user)->send(new WelcomeEmail($user));
        
        // Atualizar cache
        Cache::tags('users')->flush();
    }

    public function updated(User $user): void
    {
        // Log de auditoria
        Log::info("User {$user->id} was updated", $user->getChanges());
    }

    public function deleting(User $user): void
    {
        // Remover dados relacionados
        $user->posts()->delete();
    }
}

// Registrar no AppServiceProvider:
User::observe(UserObserver::class);
```

**Comandos úteis:**
```bash
make make:observer         # Criar observer
make make-observable-model # Criar model + observer
```

---

### 🛠️ `app/Utils/` - Utilitários Genéricos

**Função:** Funções ou classes utilitárias sem estado e que não se encaixam em nenhuma outra categoria.

**Responsabilidade:** Helpers puros, formatação de dados, cálculos, etc.

**Exemplo:**

```php
// app/Utils/CpfHelper.php
class CpfHelper
{
    public static function format(string $cpf): string
    {
        return preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $cpf);
    }

    public static function validate(string $cpf): bool
    {
        $cpf = preg_replace('/[^0-9]/', '', $cpf);
        
        if (strlen($cpf) !== 11) {
            return false;
        }

        // ... lógica de validação de CPF
        return true;
    }
}

// app/Utils/MoneyHelper.php
class MoneyHelper
{
    public static function format(float $value): string
    {
        return 'R$ ' . number_format($value, 2, ',', '.');
    }

    public static function toCents(float $value): int
    {
        return (int) ($value * 100);
    }
}
```

---

### 🔄 `app/Traits/` - Código Reutilizável de Classe

**Função:** Traits de PHP para compartilhar métodos em Models ou outras classes.

**Responsabilidade:** Compartilhar comportamento comum entre classes.

**Exemplo:**

```php
// app/Traits/HasUuid.php
trait HasUuid
{
    protected static function bootHasUuid(): void
    {
        static::creating(function ($model) {
            if (empty($model->uuid)) {
                $model->uuid = Str::uuid()->toString();
            }
        });
    }
}

// app/Traits/Searchable.php
trait Searchable
{
    public function scopeSearch($query, string $term)
    {
        return $query->where(function ($q) use ($term) {
            foreach ($this->searchable ?? [] as $column) {
                $q->orWhere($column, 'LIKE', "%{$term}%");
            }
        });
    }
}

// Uso:
class User extends Model
{
    use HasUuid, Searchable;

    protected array $searchable = ['name', 'email'];
}

// Buscar:
User::search('john')->get();
```

**Comandos úteis:**
```bash
make make:trait            # Criar trait
```

---

### 📦 `app/DTOs/` - Data Transfer Objects

**Função:** Objetos para transferir dados entre camadas.

**Responsabilidade:** Encapsular dados de forma tipada e imutável.

**Exemplo:**

```php
// app/DTOs/CreateUserDTO.php
class CreateUserDTO
{
    public function __construct(
        public readonly string $name,
        public readonly string $email,
        public readonly string $password,
        public readonly ?string $phone = null
    ) {}

    public static function fromRequest(array $data): self
    {
        return new self(
            name: $data['name'],
            email: $data['email'],
            password: $data['password'],
            phone: $data['phone'] ?? null
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
            'password' => $this->password,
            'phone' => $this->phone,
        ];
    }
}
```

**Comandos úteis:**
```bash
make make-dto              # Criar DTO
```

---

## 🔄 Fluxo de Dados

### Criação de Recurso (POST):

```
1. Request HTTP → Controller
   ↓
2. Controller → Form Request (validação)
   ↓
3. Controller → Service (lógica de negócio)
   ↓
4. Service → Repository (acesso a dados)
   ↓
5. Repository → Model (Eloquent)
   ↓
6. Model → Database
   ↓
7. Database → Model (retorno)
   ↓
8. Model → Repository → Service → Controller
   ↓
9. Controller → API Resource (formatação)
   ↓
10. API Resource → Response JSON
```

### Consulta de Recurso (GET):

```
1. Request HTTP → Controller
   ↓
2. Controller → Service
   ↓
3. Service → Repository
   ↓
4. Repository → Model (query)
   ↓
5. Model → Database
   ↓
6. Database → Model (retorno)
   ↓
7. Model → Repository → Service → Controller
   ↓
8. Controller → API Resource
   ↓
9. API Resource → Response JSON
```

---

## 🎯 Comandos Úteis

### Criar Estrutura Completa

```bash
# Criar todas as pastas de arquitetura
make setup-architecture
```

### Criar Componentes Individuais

```bash
# Camada de Negócio
make make-service              # Criar Service
make make-action               # Criar Action

# Camada de Dados
make make-repository           # Criar Repository + Interface

# Camada de Persistência
make make:model                # Criar Model
make make-observable-model     # Criar Model + Observer

# Utilitários
make make-dto                  # Criar DTO
make make:enum                 # Criar Enum
make make:trait                # Criar Trait

# Camada de Transporte
make make:controller           # Criar Controller
make make:request              # Criar Form Request
make make:resource             # Criar API Resource

# Completo (API Resource Full)
make make-api-resource-full    # Model + Controller + Resource + Requests
```

---

## ✅ Boas Práticas

### ✅ FAÇA:

- **Controllers magros**: Apenas delegue para Services
- **Services focados**: Um Service por domínio/contexto
- **Repositories simples**: Apenas queries e acesso a dados
- **Models burros**: Apenas relacionamentos e accessors/mutators
- **Actions únicas**: Uma ação por classe
- **Enums sempre**: Evite "magic strings"
- **Observers reativos**: Para efeitos colaterais automáticos
- **Utils puros**: Funções sem estado e reutilizáveis

### ❌ NÃO FAÇA:

- ❌ Lógica de negócio no Controller
- ❌ Queries complexas no Controller
- ❌ Lógica de negócio no Model
- ❌ Service gigante com 50+ métodos
- ❌ Repository sem interface
- ❌ Strings mágicas em vez de Enums
- ❌ Lógica de formatação no Model

---

## 📚 Recursos Adicionais

- [Laravel Documentation](https://laravel.com/docs)
- [Repository Pattern](https://designpatternsphp.readthedocs.io/en/latest/More/Repository/README.html)
- [Service Layer Pattern](https://martinfowler.com/eaaCatalog/serviceLayer.html)
- [PHP Enums](https://www.php.net/manual/en/language.enumerations.php)

---

## 🚀 Início Rápido

```bash
# 1. Subir containers
make up

# 2. Criar estrutura de arquitetura
make setup-architecture

# 3. Criar um recurso completo (exemplo: Post)
make make-api-resource-full   # Digite: Post

# 4. Criar Service para Post
make make-service             # Digite: PostService

# 5. Criar Repository para Post
make make-repository          # Digite: PostRepository

# 6. Ajustar Controller para usar Service
# Editar: backend/app/Http/Controllers/PostController.php

# 7. Implementar lógica no Service
# Editar: backend/app/Services/PostService.php

# 8. Implementar queries no Repository
# Editar: backend/app/Repositories/PostRepository.php

# 9. Rodar migrations
make migrate

# 10. Testar API
curl http://localhost:8080/api/posts
```

---

## 💡 Dúvidas?

Execute `make help` para ver todos os comandos disponíveis!

---

**Desenvolvido com ❤️ usando Laravel + Docker**

