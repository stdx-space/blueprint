import { Context, Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { logger } from 'hono/logger';
import { requestId } from 'hono/request-id';

interface Env {
	modules: KVNamespace;
	artifact: R2Bucket;
}

interface CreateModuleRequest {
	name: string;
	namespace: string;
	provider: string;
	description: string;
	owner: string;
	source: string;
}

interface Module extends CreateModuleRequest {
	id: string;
	verified: boolean;
	downloads: number;
	published_at: string;
}

const basePath = '/v1/modules/';

const app = new Hono<{ Bindings: Env }>();
const registry = new Hono().basePath(basePath);
app.use(logger());
app.use('*', requestId());

const serviceDiscoveryResponse = {
	'modules.v1': basePath,
};

app.get('/healthz', async (context: Context) => context.json({ status: 'ok' }));
app.get('/', async (context: Context) => context.json(serviceDiscoveryResponse));
app.get('/.well-known/terraform.json', async (context: Context) => context.json(serviceDiscoveryResponse));

registry.post(`/`, async (context: Context) => {
	const payload: CreateModuleRequest = await context.req.json();
	const id = `${payload.namespace}/${payload.name}/${payload.provider}`;
	await context.env.modules.put(
		`modules:${id}`,
		JSON.stringify({
			...payload,
			id,
			verified: true,
			downloads: 0,
			published_at: new Date().toISOString(),
		})
	);
});

registry.get(`/`, async (context: Context) => {
	const modules = await context.env.modules.list({ prefix: 'modules:' });
	// context.json({
	// 	meta: {
	// 		limit: parseInt(context.req.query('limit')!) || 0,
	// 		offset: parseInt(context.req.query('offset')!) || 0,
	// 		next_offset: ``
	// 	},
	// 	modules: modules.keys.map((key: string) => JSON.parse()),
	// });
});

registry.post(`/:namespace/:name/:provider/versions`, async (context: Context) => {
	context.json(
		{
			status: 'error',
			message: 'not implemented',
		},
		501
	);
});

registry.get(`/:namespace/:name/:provider/versions`, async (context: Context) => {
	const namespace = context.req.param('namespace');
	const name = context.req.param('name');
	const provider = context.req.param('provider');
	const result: R2Objects = await context.env.artifact.list({
		prefix: `${namespace}/${name}/${provider}`,
	});
	if (result.objects.length > 0) {
		context.json({
			modules: [
				{
					versions: result.objects.map((object) => ({
						version: object.key
							.split('/')
							.reverse()[0]
							.replace(/\.tgz$|\.zip|\.tar.gz$/, ''),
					})),
				},
			],
		});
	} else {
		throw new HTTPException(404, {
			message: 'module not found',
		});
	}
});

registry.get(`/:namespace/:name/:provider/download`, async (context: Context) => {
	context.json(
		{
			status: 'error',
			message: 'not implemented',
		},
		501
	);
});

registry.get(`/:namespace/:name/:provider/:version/download`, async (context: Context) => {
	const namespace = context.req.param('namespace');
	const name = context.req.param('name');
	const provider = context.req.param('provider');
	const version = context.req.param('version');
	const result: R2Objects = await context.env.artifact.list({
		prefix: `${namespace}/${name}/${provider}/${version}`,
	});
	if (result.objects.length > 0) {
		context.header('X-Terraform-Get', `https://artifact.narwhl.dev/modules/${result.objects[0].key}`);
		context.status(204);
	} else {
		throw new HTTPException(404, {
			message: 'module not found',
		});
	}
});

app.route('/', registry);
export default app;
