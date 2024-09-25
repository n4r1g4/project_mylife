extends Area2D

@export var max_health: int = 3  # Vida máxima do inimigo
var current_health: int  # Vida atual
@onready var enemy_animation := owner.get_node("anim_enemy")  # Referência à animação do inimigo
@onready var enemy_body := owner as CharacterBody2D  # Referência ao corpo do inimigo (CharacterBody2D)
@export var explosion_duration: float = 0.7  # Duração da animação de explosão antes de o inimigo sumir

# Inicialização
func _ready() -> void:
	current_health = max_health  # Define a vida inicial como a vida máxima
	play_default_animation()  # Toca a animação padrão no início

# Função chamada quando uma área entra em contato com a hitbox
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bola_raio"):
		print("acertou na mosca")
		area.queue_free()  # Remove o projétil

		# Reduz a vida do inimigo
		current_health -= 1
		print("Vida atual do inimigo:", current_health)

		# Se a vida for maior que 0, toca a animação de dano
		if current_health > 0:
			play_damage_animation()
		else:
			# Se a vida do inimigo chegar a zero, exploda e remova
			explode_and_destroy()

# Função para tocar a animação de dano
func play_damage_animation() -> void:
	# Para a movimentação do inimigo enquanto ele está "sofrendo" o dano
	enemy_body.velocity = Vector2.ZERO
	enemy_body.set_physics_process(false)  # Desativa o processamento de física (movimentação)

	# Toca a animação de dano
	enemy_animation.play("damage")

	# Usa um temporizador para permitir a animação de dano antes de voltar ao normal
	var timer = Timer.new()
	timer.wait_time = 0.5  # Tempo que a animação de dano deve durar
	timer.one_shot = true
	owner.add_child(timer)
	timer.start()

	# Após o tempo da animação de dano, volta à animação default e reinicia o movimento
	await timer.timeout
	play_default_animation()
	enemy_body.set_physics_process(true)  # Reativa a física para o inimigo se mover novamente

# Função que faz o inimigo explodir e sumir quando a vida chega a 0
func explode_and_destroy() -> void:
	# Para o inimigo de se mover
	enemy_body.velocity = Vector2.ZERO
	enemy_body.set_physics_process(false)  # Desativa o processamento de física (movimentação)

	# Troca para a animação de explosão
	enemy_animation.play("explosion")

	# Cria um temporizador e espera ele terminar
	var timer = Timer.new()
	timer.wait_time = explosion_duration
	timer.one_shot = true
	owner.add_child(timer)
	timer.start()

	# Espera o temporizador finalizar antes de remover o inimigo
	await timer.timeout

	owner.queue_free()  # Remove o inimigo após a animação

# Função para tocar a animação padrão enquanto o inimigo estiver vivo
func play_default_animation() -> void:
	enemy_animation.play("default")
