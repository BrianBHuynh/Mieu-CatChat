extends Node

var tasks_queue: Array

func _ready() -> void:
	SignalBus.clear_tasks.connect(clear_tasks)

func add_task(task: Callable):
	tasks_queue.append(WorkerThreadPool.add_task(Callable(self, "auto_task").bind(task), false, ""))

func auto_task(task: Callable):
	task.call()
	print("Heya")
	SignalBus.clear_tasks.emit.call_deferred()

func clear_tasks():
	for task in tasks_queue:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			print("Task cleared " + str(task))
