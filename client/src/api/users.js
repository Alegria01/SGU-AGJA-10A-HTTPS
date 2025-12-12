const ENV = import.meta.env
const API_PORT = ENV.VITE_API_PORT ? `:${ENV.VITE_API_PORT}` : ''
const API_URL = `${ENV.VITE_API_PROTOCOL}://${ENV.VITE_API_HOST}${API_PORT}${ENV.VITE_API_BASE}`

async function handleReponse(res){
    if (!res.ok){
        const errorText = await res.text().catch(()=>"")
        throw new Error(errorText || `Error HTTP ${res.status}`);

    }
    if(res.status == 204) return null;
    return res.json();
}

function unwrap (payload){
    if ( payload == null) return payload;
    if(Array.isArray(payload)) return payload;

    if(payload.data != undefined) return payload.data;
    if(payload.content !== undefined) return payload.content;
    return payload;

} 
export const UsersAPI = {
    list: async () => {
        const res = await fetch (`${API_URL}`,
            {
                headers: {
                    'Content-Type': 'application/json'
                }
            }
        );
        const json = await handleReponse(res);
        return unwrap(json);
    },
    get: async (id) => {
        const res = await fetch(`${API_URL}${id}`,
            {
                headers: {
                    'Content-Type': 'application/json'
                }
            }
        );
        const json = await handleReponse(res);
        return unwrap(json);
    },
    create: async (payload) => {
        const res = await fetch(`${API_URL}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            }
        );
        return handleReponse(res);
    },
    update: async (id, payload) => {
        const res = await fetch(`${API_URL}`,
            {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({id, ...payload}),
            }
        );
        return handleReponse(res);
    },
    remove: async (id) => {
        const res = await fetch(`${API_URL}`,
            {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({id})
            }
        );
        return handleReponse(res);
    }
}

