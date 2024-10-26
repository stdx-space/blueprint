import { Context, Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { logger } from 'hono/logger';
import { requestId } from 'hono/request-id';

export type Env = {
	artifact: R2Bucket;
};

const registry = new Hono<{ Bindings: Env }>();
registry.use(logger());
registry.use('*', requestId());

const basePath = '/v1/modules/';
const serviceDiscoveryResponse = {
	"modules.v1": basePath,
};

registry.get('/healthz', async (context: Context) => context.json({ status: 'ok' }));

registry.get('/', async (context: Context) =>
	context.json(serviceDiscoveryResponse)
);

registry.get('/.well-known/terraform.json', async (context: Context) =>
	context.json(serviceDiscoveryResponse)
);

registry.get(`${basePath}/:namespace/:name/:system/versions`, async (context: Context) => {
	const namespace = context.req.param('namespace');
	const name = context.req.param('name');
	const system = context.req.param('system');
	const result: R2Objects = await context.env.artifact.list({
		prefix: `${namespace}/${name}/${system}`
	});
	if (result.objects.length > 0) {
		context.json({
			"modules": [
				{
					"versions": result.objects.map((object) => ({
						version: object.key.split('/').reverse()[0].replace(/\.tgz$|\.zip|\.tar.gz$/, '')
					})),
				}
			]
		});
	} else {
		throw new HTTPException(404, {
			res: new Response(
				JSON.stringify({
					status: 'error',
					message: 'module not found',
				}),
			),
		});
	}
});

registry.get(`${basePath}/:namespace/:name/:system/download`, async (context: Context) => {
	context.json({
		status: 'error',
		message: 'not implemented'
	}, 501)
});

registry.get(`${basePath}/:namespace/:name/:system/:version/download`, async (context: Context) => {
	const namespace = context.req.param('namespace');
	const name = context.req.param('name');
	const system = context.req.param('system');
	const version = context.req.param('version');
	const result: R2Objects = await context.env.artifact.list({
		prefix: `${namespace}/${name}/${system}/${version}`
	});
	if (result.objects.length > 0) {
		context.header('X-Terraform-Get', `https://artifact.narwhl.dev/${result.objects[0].key}`);
		context.status(204);
	} else {
		throw new HTTPException(404, {
			res: new Response(
				JSON.stringify({
					status: 'error',
					message: 'module not found',
				}),
			),
		});
	}
});

export default registry;
