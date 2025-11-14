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

## 🎯 Princípios SOLID

Esta arquitetura foi projetada seguindo rigorosamente os **5 princípios SOLID** da programação orientada a objetos:

### 1️⃣ **S** - Single Responsibility Principle (Responsabilidade Única)

**Princípio:** *"Uma classe deve ter um, e somente um, motivo para mudar"*

**Como aplicamos:**

- ✅ **Controllers**: Apenas recebem requisições e delegam para Services
- ✅ **Services**: Apenas lógica de negócio (um domínio por Service)
- ✅ **Repositories**: Apenas acesso a dados
- ✅ **Models**: Apenas representação de dados e relacionamentos
- ✅ **Actions**: Uma ação específica por classe

**Exemplo:**

```php
// ❌ ERRADO - Controller com muitas responsabilidades
class UserController extends Controller
{
    public function store(Request $request)
    {
        // Validação
        $validated = $request->validate([...]);
        
        // Lógica de negócio
        $user = User::create($validated);
        
        // Envio de email
        Mail::to($user)->send(new WelcomeEmail($user));
        
        // Log
        Log::info("User created: {$user->id}");
        
        return response()->json($user);
    }
}

// ✅ CORRETO - Responsabilidades separadas
class UserController extends Controller
{
    public function __construct(private UserService $userService) {}
    
    public function store(StoreUserRequest $request) // Validação separada
    {
        $user = $this->userService->createUser($request->validated());
        return new UserResource($user);
    }
}

class UserService // Lógica de negócio separada
{
    public function createUser(array $data): User
    {
        $user = $this->userRepository->create($data);
        event(new UserCreated($user)); // Eventos separados
        return $user;
    }
}
```

---

### 2️⃣ **O** - Open/Closed Principle (Aberto/Fechado)

**Princípio:** *"Entidades devem estar abertas para extensão, mas fechadas para modificação"*

**Como aplicamos:**

- ✅ **Interfaces de Repository**: Permite trocar implementação sem alterar código
- ✅ **Actions**: Novas ações podem ser criadas sem modificar existentes
- ✅ **Observers**: Novos comportamentos via eventos, sem modificar Models
- ✅ **Enums**: Extensíveis via métodos, sem quebrar código existente

**Exemplo:**

```php
// ✅ Código aberto para extensão
interface UserRepositoryInterface
{
    public function create(array $data): User;
    public function findByEmail(string $email): ?User;
}

// Implementação padrão (Eloquent)
class EloquentUserRepository implements UserRepositoryInterface
{
    public function create(array $data): User
    {
        return User::create($data);
    }
}

// Nova implementação (MongoDB) - SEM modificar código existente
class MongoUserRepository implements UserRepositoryInterface
{
    public function create(array $data): User
    {
        // Lógica MongoDB
    }
}

// Service não precisa mudar, funciona com qualquer implementação
class UserService
{
    public function __construct(
        private UserRepositoryInterface $userRepository // Interface!
    ) {}
}
```

---

### 3️⃣ **L** - Liskov Substitution Principle (Substituição de Liskov)

**Princípio:** *"Objetos de uma superclasse devem ser substituíveis por objetos de suas subclasses sem quebrar a aplicação"*

**Como aplicamos:**

- ✅ **Repository Interface**: Qualquer implementação pode substituir outra
- ✅ **Actions**: Podem implementar interface comum e serem intercambiáveis
- ✅ **DTOs**: Consistência de estrutura de dados

**Exemplo:**

```php
// ✅ Implementações intercambiáveis
interface PaymentGatewayInterface
{
    public function charge(float $amount): Payment;
}

class StripePaymentGateway implements PaymentGatewayInterface
{
    public function charge(float $amount): Payment
    {
        // Lógica Stripe
        return new Payment([...]);
    }
}

class PayPalPaymentGateway implements PaymentGatewayInterface
{
    public function charge(float $amount): Payment
    {
        // Lógica PayPal
        return new Payment([...]);
    }
}

// Service funciona com QUALQUER gateway
class PaymentService
{
    public function __construct(
        private PaymentGatewayInterface $gateway
    ) {}
    
    public function processPayment(Order $order): Payment
    {
        return $this->gateway->charge($order->total);
    }
}
```

---

### 4️⃣ **I** - Interface Segregation Principle (Segregação de Interface)

**Princípio:** *"Muitas interfaces específicas são melhores que uma interface única"*

**Como aplicamos:**

- ✅ **Repositories/Contracts**: Interfaces pequenas e específicas
- ✅ **Actions**: Cada action tem sua própria interface
- ✅ **Traits**: Comportamentos específicos e opcionais

**Exemplo:**

```php
// ❌ ERRADO - Interface "gorda" com métodos que nem todos precisam
interface UserRepositoryInterface
{
    public function create(array $data): User;
    public function update(User $user, array $data): User;
    public function delete(User $user): bool;
    public function export(): string; // Nem todos precisam disso
    public function import(string $file): void; // Nem todos precisam disso
    public function generateReport(): array; // Nem todos precisam disso
}

// ✅ CORRETO - Interfaces segregadas
interface UserRepositoryInterface
{
    public function create(array $data): User;
    public function update(User $user, array $data): User;
    public function delete(User $user): bool;
}

interface ExportableRepositoryInterface
{
    public function export(): string;
}

interface ImportableRepositoryInterface
{
    public function import(string $file): void;
}

interface ReportableRepositoryInterface
{
    public function generateReport(): array;
}

// Implementação escolhe quais interfaces implementar
class UserRepository implements 
    UserRepositoryInterface,
    ExportableRepositoryInterface // Apenas se precisar
{
    // ...
}
```

---

### 5️⃣ **D** - Dependency Inversion Principle (Inversão de Dependência)

**Princípio:** *"Dependa de abstrações, não de implementações concretas"*

**Como aplicamos:**

- ✅ **Repository Pattern**: Services dependem de interfaces, não de implementações
- ✅ **Dependency Injection**: Laravel injeta dependências automaticamente
- ✅ **Service Container**: Bind de interfaces para implementações

**Exemplo:**

```php
// ❌ ERRADO - Dependência de classe concreta
class UserService
{
    public function __construct(
        private EloquentUserRepository $userRepository // Concreto!
    ) {}
}

// ✅ CORRETO - Dependência de abstração
class UserService
{
    public function __construct(
        private UserRepositoryInterface $userRepository // Interface!
    ) {}
}

// Configuração no AppServiceProvider
public function register(): void
{
    $this->app->bind(
        UserRepositoryInterface::class,
        EloquentUserRepository::class // Pode trocar facilmente
    );
}

// Agora podemos trocar a implementação sem alterar UserService:
$this->app->bind(
    UserRepositoryInterface::class,
    CachedUserRepository::class // Nova implementação!
);
```

---

## 🎨 Padrões de Projeto (Design Patterns)

Esta arquitetura implementa diversos **Design Patterns** clássicos:

### 1. **Repository Pattern** 🏛️

**Onde:** `app/Repositories/`

**Objetivo:** Abstrair o acesso a dados, isolando a lógica de persistência.

**Benefícios:**
- ✅ Facilita mudança de banco de dados
- ✅ Facilita testes (mock do Repository)
- ✅ Centraliza queries complexas

**Estrutura:**

```php
// Interface (Contrato)
interface UserRepositoryInterface
{
    public function create(array $data): User;
    public function findByEmail(string $email): ?User;
}

// Implementação
class EloquentUserRepository implements UserRepositoryInterface
{
    public function create(array $data): User
    {
        return User::create($data);
    }
    
    public function findByEmail(string $email): ?User
    {
        return User::where('email', $email)->first();
    }
}

// Uso no Service
class UserService
{
    public function __construct(
        private UserRepositoryInterface $userRepository
    ) {}
    
    public function createUser(array $data): User
    {
        return $this->userRepository->create($data);
    }
}
```

---

### 2. **Service Layer Pattern** ⚙️

**Onde:** `app/Services/`

**Objetivo:** Encapsular lógica de negócio complexa e orquestrar múltiplas operações.

**Benefícios:**
- ✅ Controllers magros
- ✅ Reutilização de lógica
- ✅ Facilita testes unitários

**Estrutura:**

```php
class OrderService
{
    public function __construct(
        private OrderRepository $orderRepository,
        private PaymentService $paymentService,
        private EmailService $emailService,
        private InventoryService $inventoryService
    ) {}
    
    public function placeOrder(array $data): Order
    {
        DB::beginTransaction();
        try {
            // 1. Criar pedido
            $order = $this->orderRepository->create($data);
            
            // 2. Processar pagamento
            $payment = $this->paymentService->processPayment($order);
            
            // 3. Atualizar estoque
            $this->inventoryService->decreaseStock($order->items);
            
            // 4. Enviar email
            $this->emailService->sendOrderConfirmation($order);
            
            DB::commit();
            return $order;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

---

### 3. **Action/Command Pattern** 🎯

**Onde:** `app/Actions/`

**Objetivo:** Encapsular uma única ação/operação em uma classe.

**Benefícios:**
- ✅ Single Responsibility
- ✅ Testável isoladamente
- ✅ Reutilizável

**Estrutura:**

```php
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
            method: $paymentData['method']
        );
        
        $this->orderRepository->markAsPaid($order, $payment);
        
        return $payment;
    }
}

// Uso
$payment = app(ProcessPaymentAction::class)->execute($order, $paymentData);
```

---

### 4. **Observer Pattern** 👁️

**Onde:** `app/Observers/`

**Objetivo:** Reagir a eventos do Model automaticamente.

**Benefícios:**
- ✅ Desacoplamento
- ✅ Efeitos colaterais organizados
- ✅ Fácil adicionar novos comportamentos

**Estrutura:**

```php
class UserObserver
{
    public function created(User $user): void
    {
        // Enviar email de boas-vindas
        Mail::to($user)->send(new WelcomeEmail($user));
        
        // Criar perfil padrão
        $user->profile()->create([
            'bio' => '',
            'avatar' => 'default.png'
        ]);
        
        // Log
        Log::info("New user registered: {$user->email}");
    }
    
    public function updated(User $user): void
    {
        // Limpar cache
        Cache::forget("user:{$user->id}");
    }
}

// Registrar no AppServiceProvider
User::observe(UserObserver::class);
```

---

### 5. **Data Transfer Object (DTO) Pattern** 📦

**Onde:** `app/DTOs/`

**Objetivo:** Transferir dados entre camadas de forma tipada e imutável.

**Benefícios:**
- ✅ Type-safety
- ✅ Imutabilidade
- ✅ Validação centralizada

**Estrutura:**

```php
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
            'password' => bcrypt($this->password),
            'phone' => $this->phone,
        ];
    }
}

// Uso
$dto = CreateUserDTO::fromRequest($request->validated());
$user = $this->userService->create($dto);
```

---

### 6. **Strategy Pattern** 🎲

**Onde:** `app/Services/` + Interfaces

**Objetivo:** Permitir troca de algoritmos/estratégias em tempo de execução.

**Benefícios:**
- ✅ Flexibilidade
- ✅ Fácil adicionar novas estratégias
- ✅ Testável

**Estrutura:**

```php
// Estratégias de pagamento
interface PaymentStrategyInterface
{
    public function pay(float $amount): Payment;
}

class CreditCardStrategy implements PaymentStrategyInterface
{
    public function pay(float $amount): Payment
    {
        // Lógica cartão de crédito
    }
}

class PixStrategy implements PaymentStrategyInterface
{
    public function pay(float $amount): Payment
    {
        // Lógica PIX
    }
}

// Context
class PaymentService
{
    public function processPayment(
        float $amount,
        PaymentStrategyInterface $strategy
    ): Payment {
        return $strategy->pay($amount);
    }
}

// Uso
$payment = $paymentService->processPayment(
    amount: 100.00,
    strategy: new PixStrategy()
);
```

---

### 7. **Factory Pattern** 🏭

**Onde:** `app/Services/Factories/`

**Objetivo:** Criar objetos complexos sem expor a lógica de criação.

**Benefícios:**
- ✅ Centraliza criação
- ✅ Fácil testar
- ✅ Reutilizável

**Estrutura:**

```php
class OrderFactory
{
    public function create(User $user, array $items): Order
    {
        return Order::create([
            'user_id' => $user->id,
            'total' => $this->calculateTotal($items),
            'status' => OrderStatus::PENDING,
            'items' => $items,
        ]);
    }
    
    private function calculateTotal(array $items): float
    {
        return collect($items)->sum(fn($item) => $item['price'] * $item['qty']);
    }
}
```

---

### 8. **Decorator Pattern** 🎁

**Onde:** `app/Repositories/` (Repository com Cache)

**Objetivo:** Adicionar comportamento a um objeto sem modificá-lo.

**Benefícios:**
- ✅ Composição sobre herança
- ✅ Flexível
- ✅ Open/Closed Principle

**Estrutura:**

```php
// Repository base
class UserRepository implements UserRepositoryInterface
{
    public function find(int $id): ?User
    {
        return User::find($id);
    }
}

// Decorator com cache
class CachedUserRepository implements UserRepositoryInterface
{
    public function __construct(
        private UserRepositoryInterface $repository
    ) {}
    
    public function find(int $id): ?User
    {
        return Cache::remember(
            key: "user:{$id}",
            ttl: 3600,
            callback: fn() => $this->repository->find($id)
        );
    }
}

// Binding
$this->app->bind(UserRepositoryInterface::class, function ($app) {
    return new CachedUserRepository(
        new UserRepository()
    );
});
```

---

## 📊 Resumo: SOLID + Design Patterns na Arquitetura

| Princípio/Pattern | Onde Aplicamos | Benefício Principal |
|-------------------|----------------|---------------------|
| **S** - Single Responsibility | Services, Controllers, Actions | Manutenibilidade |
| **O** - Open/Closed | Interfaces, Observers | Extensibilidade |
| **L** - Liskov Substitution | Repository Interfaces | Intercambiabilidade |
| **I** - Interface Segregation | Repositories/Contracts | Flexibilidade |
| **D** - Dependency Inversion | DI Container, Interfaces | Desacoplamento |
| **Repository Pattern** | app/Repositories/ | Abstração de dados |
| **Service Layer** | app/Services/ | Lógica de negócio |
| **Action/Command** | app/Actions/ | Single responsibility |
| **Observer** | app/Observers/ | Reatividade |
| **DTO** | app/DTOs/ | Type-safety |
| **Strategy** | Services + Interfaces | Algoritmos intercambiáveis |
| **Factory** | Services/Factories/ | Criação complexa |
| **Decorator** | Repositories (Cache) | Comportamento adicional |

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

