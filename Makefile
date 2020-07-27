out/ip: out/terraform.log
	tail out/terraform.log | awk '/^ip = / { print $$3 }' > out/ip

out/terraform.log:
	mkdir -p out
	terraform apply -no-color -auto-approve | tee out/terraform.log

destroy: clean
	terraform destroy -auto-approve

clean:
	rm -rf out

status:
	scripts/inspect-acct
ssh:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		$(shell cat out/ip)

tail:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		$(shell cat out/ip) \
		sudo tail -n 100 -f /home/rust/rustserver/nohup.out
