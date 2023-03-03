resource "aws_iam_user" "main" {
  count = length(var.usernames)
  name  = element(var.usernames, count.index)
}

data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "attachment" {
  count      = length(var.usernames)
  user       = element(var.usernames, count.index)
  policy_arn = data.aws_iam_policy.ReadOnlyAccess.arn
}

output "user_arn" {
  value = aws_iam_user.main.*.arn
}
