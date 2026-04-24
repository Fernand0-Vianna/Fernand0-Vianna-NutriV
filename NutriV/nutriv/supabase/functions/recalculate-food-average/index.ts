import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Edge Function para recalcular a média nutricional de um alimento
// Útil para manutenção ou quando necessário recalcular manualmente

interface RequestBody {
  food_id: string;
}

Deno.serve(async (req: Request) => {
  // Verificar método
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Método não permitido. Use POST.' }),
      { status: 405, headers: { 'Content-Type': 'application/json' } }
    );
  }

  try {
    const body: RequestBody = await req.json();
    const { food_id } = body;

    if (!food_id) {
      return new Response(
        JSON.stringify({ error: 'food_id é obrigatório' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Chamar a função SQL para recalcular a média
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { error } = await supabase.rpc('calculate_food_nutrition_average', {
      p_food_id: food_id
    });

    if (error) {
      throw error;
    }

    // Buscar os valores atualizados
    const { data: food, error: fetchError } = await supabase
      .from('foods')
      .select('id, name, calories, protein, carbs, fat, fiber, serving_size')
      .eq('id', food_id)
      .single();

    if (fetchError) {
      throw fetchError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Média recalculada com sucesso',
        food: food
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: 'Erro ao recalcular média',
        details: error.message 
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});

// Função auxiliar para criar cliente Supabase (simplificada)
function createClient(url: string, key: string) {
  return {
    rpc: async (fn: string, params: Record<string, unknown>) => {
      const response = await fetch(`${url}/rest/v1/rpc/${fn}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${key}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(params),
      });
      if (!response.ok) {
        const error = await response.text();
        throw new Error(error);
      }
      return { error: null };
    },
    from: (table: string) => ({
      select: (...columns: string[]) => ({
        eq: (column: string, value: string) => ({
          single: async () => {
            const response = await fetch(
              `${url}/rest/v1/${table}?select=${columns.join(',')}&${column}=eq.${value}`,
              {
                headers: {
                  'Authorization': `Bearer ${key}`,
                  'Content-Type': 'application/json',
                },
              }
            );
            if (!response.ok) {
              return { data: null, error: await response.text() };
            }
            const data = await response.json();
            return { data: data[0], error: null };
          }
        })
      })
    }),
  };
}
