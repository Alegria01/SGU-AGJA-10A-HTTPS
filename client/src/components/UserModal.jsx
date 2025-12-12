import { useEffect, useState } from "react";

export default function UserModal({
  show,
  mode = "create",
  initialData = { name: "", email: "", phone: "" },
  onClose,
  onSubmit,
  saving = false,
}) {
  const [form, setForm] = useState(initialData);
  const [errors, setErrors] = useState({});

  useEffect(() => {
    setForm(initialData);
    setErrors({});
  }, [initialData, show]);

  const validate = () => {
    const e = {};
    if (!form.name?.trim()) e.name = "Requerido";
    if (!form.email?.trim()) e.email = "Requerido";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) e.email = "Email inválido";
    if (!form.phone?.trim()) e.phone = "Requerido";
    else if (!/^[0-9]{7,15}$/.test(form.phone.replace(/\D/g, ''))) e.phone = "Teléfono inválido";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = (ev) => {
    ev.preventDefault();
    if (!validate()) return;
    onSubmit(form);
  };

  const handleBackdropClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  if (!show) return null;

  return (
    <div className="modal-overlay" onClick={handleBackdropClick} role="dialog" aria-modal="true">
      <div className="modal-panel glass" style={{ maxWidth: 560 }}>
        <div className="modal-header" style={{alignItems:'center'}}>
          <div>
            <h5 className="modal-title">{mode === "create" ? "Nuevo usuario" : "Editar usuario"}</h5>
            <div style={{fontSize:'.85rem', color:'var(--muted)'}}>{mode === 'create' ? 'Crear un nuevo registro' : 'Modifica los datos del usuario'}</div>
          </div>
          <div>
            <button className="icon-btn" onClick={onClose} aria-label="Cerrar" disabled={saving}>✕</button>
          </div>
        </div>

        <form onSubmit={handleSubmit} noValidate>
          <div className="modal-body">
            <div className="mb-3">
              <label className="form-label">Nombre</label>
              <input
                type="text"
                className={`form-control ${errors.name ? "is-invalid" : ""}`}
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                disabled={saving}
              />
              {errors.name && <div className="invalid-feedback">{errors.name}</div>}
            </div>

            <div className="mb-3">
              <label className="form-label">Email</label>
              <input
                type="email"
                className={`form-control ${errors.email ? "is-invalid" : ""}`}
                value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })}
                disabled={saving}
              />
              {errors.email && <div className="invalid-feedback">{errors.email}</div>}
            </div>

            <div className="mb-3">
              <label className="form-label">Teléfono</label>
              <input
                type="text"
                className={`form-control ${errors.phone ? "is-invalid" : ""}`}
                value={form.phone}
                onChange={(e) => setForm({ ...form, phone: e.target.value })}
                disabled={saving}
              />
              {errors.phone && <div className="invalid-feedback">{errors.phone}</div>}
            </div>
          </div>

          <div className="modal-footer" style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
            <div style={{color:'var(--muted)'}}>
              {mode === 'create' ? 'Al crear se añadirá al listado.' : 'Los cambios se guardarán en la base de datos.'}
            </div>
            <div>
              <button type="button" className="btn btn-outline-secondary me-2" onClick={onClose} disabled={saving}>Cancelar</button>
              <button type="submit" className="btn btn-primary" disabled={saving}>{saving ? 'Guardando...' : mode === 'create' ? 'Crear usuario' : 'Guardar cambios'}</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
