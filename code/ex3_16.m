1; % Treat this as a script file

function def_integral = integrate_pdf(pdf_fn, l, u)
  [q, ier, nfun, err] = quad(pdf_fn, l, u);
  assert(ier == 0, "Integration of Beta pdf failed");
  def_integral = q;
endfunction

function F_a = create_F_a(m, l, u)
  pdf_a = @(a)( @(theta) betapdf(theta, a, ((a/m) .* (1-m)) - 1) );
  F_a = @(a)( integrate_pdf(pdf_a(a), l, u) );
endfunction

function cost_a = create_cost_a(m, l, u)
  F_a = create_F_a(m, l, u);
  cost_a = @(a)( (.95 - F_a(a)) .^ 2 );
endfunction

% Given in the problem statement
u = .3;
l = .05;
m = .15;

% numerical evaluation fails for a < min_a
[min_a, max_a] = deal(0.2, 10);

F_a_fn = create_F_a(m, l, u);
figure();
xlabel('a');
ylabel('F(a|u,l,m)');
title('CDF as function of a');
hold on;
plot([min_a, max_a], [.95, .95], 'linestyle', '-', 'color', 'red');

% Hack to avoid handling vector input in F_a_fn
step = .2;
y = zeros(((max_a - min_a) / step) + 1, 1);
a = min_a:step:max_a;
for i = 1:length(a)
  y(i) = F_a_fn(a(i));
endfor

plot(a, y, 'linestyle', '-', 'color', 'blue'); % plot F(a) for min_a <= a <= max_a

 % find F^{-1}(a) = .95
[a, cost, info, output, grad, hess] = fminunc(create_cost_a(m, l, u), 1);
plot(a, F_a_fn(a), 'o', 'color', 'red'); % plot a where F(a) = .95
text(a, F_a_fn(a) - .05, sprintf('(%f, %f)', a, F_a_fn(a))); % label point

b = (a/m) * (1-m);
printf('a = %f; b = %f; cost= %f\n', a, b, cost);

% Check: F(u) - F(l) ~= .95
err = betacdf(u, a, b) - betacdf(l, a, b);
printf('F(u) - F(l) = %f (this should be close to .95)\n', err);
percent_err = 100 * (.95 - err)/.95;
printf('Percent error: %f%%\n', percent_err);

% Check: Sampling from a Beta(a,b) should produce mean == m
num_trials = 10000;
printf("Sampling from a Beta(%d,%d) distribution %d times...\n", a, b, num_trials);
trials = zeros(num_trials, 1);
for i=1:num_trials
  trials(i) = betarnd(a, b);
endfor

printf('Empirical mean: %f (this should be close to %f)\n', mean(trials), m);
percent_err = 100 * (m - mean(trials))/m;
printf('Percent error: %f%%\n', percent_err);
