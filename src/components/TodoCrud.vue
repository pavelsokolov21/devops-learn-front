<script setup>
import { ref, onMounted } from "vue";
import { api } from "../api";

const todos = ref([]);
const newTitle = ref("");
const loading = ref(false);
const error = ref("");

async function loadTodos() {
  loading.value = true;
  error.value = "";
  try {
    const { data } = await api.get("/todos");
    todos.value = data;
  } catch (e) {
    error.value = e?.response?.data?.error || e.message || "Failed to load";
  } finally {
    loading.value = false;
  }
}

async function createTodo() {
  const title = newTitle.value.trim();
  if (!title) return;

  error.value = "";
  try {
    const { data } = await api.post("/todos", { title });
    todos.value = [data, ...todos.value];
    newTitle.value = "";
  } catch (e) {
    error.value = e?.response?.data?.error || e.message || "Failed to create";
  }
}

async function toggleTodo(todo) {
  error.value = "";
  try {
    const { data } = await api.put(`/todos/${todo.id}`, {
      completed: !todo.completed,
    });
    const idx = todos.value.findIndex((t) => t.id === todo.id);
    if (idx !== -1) todos.value[idx] = data;
  } catch (e) {
    error.value = e?.response?.data?.error || e.message || "Failed to update";
  }
}

async function renameTodo(todo) {
  const title = prompt("New title:", todo.title);
  if (title === null) return;

  error.value = "";
  try {
    const { data } = await api.put(`/todos/${todo.id}`, { title });
    const idx = todos.value.findIndex((t) => t.id === todo.id);
    if (idx !== -1) todos.value[idx] = data;
  } catch (e) {
    error.value = e?.response?.data?.error || e.message || "Failed to rename";
  }
}

async function deleteTodo(todo) {
  if (!confirm(`Delete "${todo.title}"?`)) return;

  error.value = "";
  try {
    await api.delete(`/todos/${todo.id}`);
    todos.value = todos.value.filter((t) => t.id !== todo.id);
  } catch (e) {
    error.value = e?.response?.data?.error || e.message || "Failed to delete";
  }
}

onMounted(loadTodos);
</script>

<template>
  <section style="max-width: 640px; margin: 24px auto; font-family: system-ui">
    <h2>Todos CRUD</h2>

    <div style="display: flex; gap: 8px; margin: 12px 0">
      <input
        v-model="newTitle"
        placeholder="New todo title"
        style="flex: 1; padding: 8px"
        @keyup.enter="createTodo"
      />
      <button @click="createTodo" style="padding: 8px 12px">Add</button>
      <button @click="loadTodos" style="padding: 8px 12px">Reload</button>
    </div>

    <p v-if="loading">Loading...</p>
    <p v-if="error" style="color: #b00020">{{ error }}</p>

    <ul style="padding-left: 16px">
      <li v-for="t in todos" :key="t.id" style="margin: 8px 0">
        <label style="display: inline-flex; align-items: center; gap: 8px">
          <input
            type="checkbox"
            :checked="t.completed"
            @change="toggleTodo(t)"
          />
          <span
            :style="{ textDecoration: t.completed ? 'line-through' : 'none' }"
          >
            {{ t.title }}
          </span>
        </label>

        <button @click="renameTodo(t)" style="margin-left: 12px">Rename</button>
        <button @click="deleteTodo(t)" style="margin-left: 6px">Delete</button>
      </li>
    </ul>
  </section>
</template>
