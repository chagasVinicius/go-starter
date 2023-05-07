package mid

import (
	"context"
	"net/http"
	"time"

	"github.com/chagasVinicius/go-starter/kit/web"
	"go.uber.org/zap"
)

// Logger writes information about the request to the logs.
func Logger(log *zap.SugaredLogger) web.Middleware {
	m := func(handler web.Handler) web.Handler {
		h := func(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
			v := web.GetValues(ctx)

			log.Infow("request started",
				"trace_id", v.TraceID,
				"web_method", r.Method,
				"web_path", r.URL.Path,
				"web_remoteaddr", r.RemoteAddr,
			)

			err := handler(ctx, w, r)

			log.Infow(
				"request completed",
				"trace_id", v.TraceID,
				"web_method", r.Method,
				"web_path", r.URL.Path,
				"web_remoteaddr", r.RemoteAddr,
				"web_status_code", v.StatusCode,
				"web_latency", time.Since(v.Now),
			)

			return err
		}

		return h
	}

	return m
}
