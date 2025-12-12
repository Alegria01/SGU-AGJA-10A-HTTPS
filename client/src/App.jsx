import { useEffect, useMemo, useState } from "react";
import { UsersAPI } from "./api/users";
import UserModal from "./components/UserModal";
import Swal from 'sweetalert2';
import 'sweetalert2/dist/sweetalert2.min.css';

function Icon({ name, size = 18 }) {
  // small inline icons (minimal, no extra deps)
  const icons = {
    plus: (
      <svg width={size} height={size} viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8 3v10M3 8h10" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
    edit: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M3 21v-3.6l11-11 3.6 3.6-11 11H3z" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
    trash: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 3h6l1 2h4v2H4V5h4l1-2z" fill="currentColor" opacity="0.06" />
        <rect x="6" y="7" width="12" height="13" rx="2" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
        <path d="M9 10v7M12 10v7M15 10v7" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
    sun: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none"><path d="M12 4v2M12 18v2M4 12H2M22 12h-2M5 5l-1.5-1.5M20 20l-1.5-1.5M5 19L3.5 20.5M20 4l-1.5 1.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="1.4"/></svg>
    ),
    moon: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none"><path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
    )
    ,
    refresh: (
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M21 12a9 9 0 10-2.6 6.04" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
        <path d="M21 3v6h-6" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    )
  };
  return icons[name] || null;
}


function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState("create");
  const [selected, setSelected] = useState(null); // usuario para editar
  const [saving, setSaving] = useState(false);

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(8);
  const [search, setSearch] = useState("");

  const filteredUsers = useMemo(() => {
    const q = (search || "").toString().trim().toLowerCase();
    if (!q) return users;
    return users.filter((u) => {
      return (
        (u.name && u.name.toString().toLowerCase().includes(q)) ||
        (u.email && u.email.toString().toLowerCase().includes(q)) ||
        (u.phone && u.phone.toString().toLowerCase().includes(q))
      );
    });
  }, [users, search]);

  const totalPages = useMemo(() => Math.max(1, Math.ceil(filteredUsers.length / pageSize)), [filteredUsers, pageSize]);
  const pagedUsers = useMemo(() => {
    const start = (page - 1) * pageSize;
    return filteredUsers.slice(start, start + pageSize);
  }, [filteredUsers, page, pageSize]);

  const [theme, setTheme] = useState(() => localStorage.getItem("theme") || "dark");

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("theme", theme);
  }, [theme]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError("");
      const data = await UsersAPI.list();
      setUsers(Array.isArray(data) ? data : data?.content || []); // por si tu API regresa {content: [...]} estilo Spring Data
      setPage(1);
    } catch (e) {
      setError(e.message || "Error cargando usuarios");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const openCreate = () => {
    setModalMode("create");
    setSelected({ name: "", email: "", phone: "" });
    setShowModal(true);
  };

  // la carga de usuarios se realiza desde la API (UsersAPI.list)

  const openEdit = (u) => {
    setModalMode("edit");
    setSelected({ id: u.id, name: u.name, email: u.email, phone: u.phone });
    setShowModal(true);
  };

  const closeModal = () => setShowModal(false);

  const handleSubmit = async (form) => {
    try {
      setSaving(true);
      if (modalMode === "create") {
        await UsersAPI.create(form);
        // toast
      } else {
        await UsersAPI.update(selected.id, form);
      }
      await loadUsers();
      setShowModal(false);
      Swal.fire({
        icon: 'success',
        title: modalMode === 'create' ? 'Usuario creado' : 'Usuario actualizado',
        showConfirmButton: false,
        timer: 1400
      });
    } catch (e) {
      Swal.fire({ icon: 'error', title: 'Error', text: e.message || 'Ocurrió un error al guardar' });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (u) => {
    const res = await Swal.fire({
      title: `¿Eliminar a ${u.name}?`,
      text: 'Esta acción no se puede deshacer',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar'
    });
    if (!res.isConfirmed) return;
    try {
      await UsersAPI.remove(u.id);
      await loadUsers();
      Swal.fire({ icon: 'success', title: 'Eliminado', text: 'Usuario eliminado', timer: 1200, showConfirmButton: false });
    } catch (e) {
      Swal.fire({ icon: 'error', title: 'Error', text: e.message || 'No se pudo eliminar' });
    }
  };
  // new layout: sidebar + main, large cards, FAB
  const [expandedId, setExpandedId] = useState(null);

  const toggleExpand = (id) => setExpandedId((cur) => (cur === id ? null : id));

  return (
    <div className="app-shell">
      <aside className="sidebar glass">
        <div className="brand">
          <div className="logo-mark">Users</div>
          <div className="brand-name">Gestión · Usuarios</div>
        </div>

        <div className="sidebar-search">
          <input
            className="form-control"
            placeholder="Buscar usuarios..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          />
        </div>

        <nav className="sidebar-nav">
          <button className="nav-item active">Usuarios</button>
          <button className="nav-item">Ajustes</button>
        </nav>

        <div>
          {/* Espacio reservado para acciones futuras (p.ej. export, import) */}
        </div>

        <div className="theme-toggle">
          <button className="icon-btn" title="Cambiar tema" onClick={() => setTheme((t) => (t === "dark" ? "light" : "dark"))}>
            {theme === "dark" ? <Icon name="sun" size={20} /> : <Icon name="moon" size={20} />}
          </button>
        </div>
      </aside>

      <main className="main-area">
        <header className="main-header glass">
          <h1>Usuarios</h1>
          <div className="header-actions">
            <div className="result-count">{filteredUsers.length} resultados</div>
            <button className="btn btn-outline-secondary icon-btn" title="Refrescar" onClick={() => { setSearch(""); loadUsers(); }} disabled={loading}>
              <Icon name="refresh" size={18} />
            </button>
          </div>
        </header>

        <section className="cards-area">
          {loading ? (
            Array.from({ length: pageSize }).map((_, i) => (
              <article key={i} className="big-card skeleton">
                <div className="big-avatar skeleton-avatar" />
                <div className="big-body">
                  <div className="skeleton-line" style={{width: '50%'}} />
                  <div className="skeleton-subline" style={{width: '40%'}} />
                </div>
              </article>
            ))
          ) : filteredUsers.length === 0 ? (
            <div className="no-results">No se encontraron usuarios.</div>
          ) : (
            <div className="big-grid">
              {pagedUsers.map((u) => (
                <article key={u.id ?? u.email} className={`big-card glass neon ${expandedId === u.id ? 'expanded' : ''}`} tabIndex={0}>
                  <div className="big-left">
                    <div className="big-avatar" aria-hidden>{u.name ? u.name.charAt(0).toUpperCase() : 'U'}</div>
                  </div>
                  <div className="big-body">
                    <div className="big-name">{u.name}</div>
                    <div className="big-meta">{u.email}</div>
                  </div>
                  <div className="big-actions">
                    <button className="icon-btn" onClick={() => openEdit(u)} title="Editar"><Icon name="edit" size={20} /></button>
                    <button className="icon-btn danger" onClick={() => handleDelete(u)} title="Eliminar"><Icon name="trash" size={20} /></button>
                    <button className="icon-btn" onClick={() => toggleExpand(u.id)} title="Detalles"><Icon name={expandedId === u.id ? 'plus' : 'plus'} size={18} /></button>
                  </div>
                  {expandedId === u.id && (
                    <div className="expanded-panel">
                      <p><strong>Detalles:</strong></p>
                      <p>Email: {u.email}</p>
                      <p>Tel: {u.phone}</p>
                    </div>
                  )}
                </article>
              ))}
            </div>
          )}
        </section>

  <button className="fab" onClick={openCreate} aria-label="Nuevo usuario"><Icon name="plus" size={26} />
  </button>

  <footer className="main-footer glass">Sistema Gestión de Usuarios</footer>
      </main>

      <UserModal
        show={showModal}
        mode={modalMode}
        initialData={selected || { name: "", email: "", phone: "" }}
        onClose={closeModal}
        onSubmit={handleSubmit}
        saving={saving}
      />
    </div>
  );
}

export default App;
