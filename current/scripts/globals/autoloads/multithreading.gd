extends Node

var tasks_queue: Array

func _ready() -> void:
	SignalBus.clear_tasks.connect(clear_tasks)

func _process(_delta: float) -> void:
	if not tasks_queue.is_empty():
		clear_tasks()

func add_task(task: Callable) -> void:
	tasks_queue.append(WorkerThreadPool.add_task(task))

func clear_tasks() -> void:
	for task: int in tasks_queue:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			tasks_queue.erase(task)
