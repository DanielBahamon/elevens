json.extract! user, :id, :slug

json.sgid user.attachable_sgid
json.content render(partial: "users/user", locals: {user: user}, formats: [:html])