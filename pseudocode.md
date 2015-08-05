# tempo contínuo, espaço contínuo

cada INDIVIDUO possui {
	CLASSE, o estágio vital do indivíduo
	S, a taxa de sobrevivência
	R, a taxa de reprodução
	G, a taxa de crescimento
	LAMBDA, a soma das taxas vitais
	POSICAO, um par de coordenadas X e Y
}

a ESPECIE possui {
	NUMCLASSES, o número de estágios de vida
	NOMECLASSES, lista dos estágios de vida
	LG, lista de taxas de crescimento para cada estágio de vida
	LR, lista de taxas de reprdução para cada estágio de vida
	LS, lista de funções que determinam as taxas de sobrevivência para cada estágio de vida, em função de um coeficiente de estresse ambiental e de um coeficiente de interações interespecíficas, fornecidos pela ARENA em função da posição (X,Y) de um indivíduo
	LR, lista de raios de copa por estágio de vida
	KERNEL, kernel de disperção de sementes produzidas
	POPULACAO, uma lista de INDIVIDUOS
	ACUMULADO, soma dos LAMBDAS de todos os INDIVIDUOS
}

a ARENA possui {
	ESPECIES, uma lista de espécies presentes nesta arena
	ACUMULADO GERAL, uma soma de todos os ACUMULADOS de todas as espécies
	INTERACOES, uma matriz de coeficientes de interações interespecíficas, negativas ou positivas
	AMBIENTE(X,Y), uma função que informa o coeficiente de estresse ambiental na posição (X,Y)
}

rotinas de criação de individuos {
	CRIAR INDIVIDUO {
		1 - recebe como parâmetro a posição (X,Y) onde o indivíduo será criado e a CLASSE c do indivíduo
		2 - identifica quais as taxas de crescimento (G) e reprodução (R) correspondentes à CLASSE c
		3 - verifica na ARENA quais INTERAÇOES existem
		4 - para cada ESPECIE com a qual há INTERACAO, verifica se existe na ARENA indivíduos dessa ESPECIE próximos a (X,Y)
		5 - verifica qual o AMBIENTE(X,Y)
		6 - calcula a taxa de sobrevivência (S) de acordo com as INTERAÇOES encontradas e com o AMBIENTE
		7 - determina a soma das taxas vitais, S+G+R = LAMBDA
		8 - cria INDIVIDUO com a posição (X,Y), CLASSE c e as taxas determinadas acima
		9 - adiciona o indivíduo à POPULACAO
	}

}

INICIALIZAÇÃO {
	I) RECEBE como parâmetros {
		NS, número inicial de semente
		NP, número inicial de plantulas
		NA, número inicial de adultas
		NF, número de facilitadoras
	}

	II) inicializa as ESPECIES BENEFICIADA e FACILITADORA, com listas de POPULACAO vazias

	III) cria ARENA com a lista de ESPECIES contendo BENEFICIADA e FACILITADORA, e com ACUMULADO GERAL = 0, e INTERAÇOES representando a facilitação da FACILITADORA sobre a BENEFICIEDA

	IV) repete NF vezes {
		1 - sorteia aleatoriamente uma posição (X,Y)
		2 - cria FACILITADORA nessa posição
	}

	V) repete NS vezes {
		1 - sorteia aleatoriamente uma posição (X,Y)
		2 - CRIA BENEFICIADA com CLASSE semente na posição (X,Y)
	}

	VI) repete NP vezes {
		1 - sorteia aleatoriamente uma posição (X,Y)
		2 - CRIA BENEFICIADA com CLASSE plântula na posição (X,Y)
	}

	VII) repete NA vezes {
		1 - sorteia aleatoriamente uma posição (X,Y)
		2 - CRIA BENEFICIADA com CLASSE adulta na posição (X,Y)
	}
}

TURNO {

	I) determina ACUMULADO, a soma dos LAMBAs de todos os INDIVIDUOs.

	II) sorteia o tempo para a próxima ação, T ~ Exponencial(ACUMULADO)

	III) adiciona esse tempo T ao contador de tempo

	IV) sorteia um indivíduo entre todos, onde a probabilidade para cada indivíduo I é LAMBDA(I)/ACUMULADO

	V) ação do indivíduo selecionado{
		1 - sorteia se o indivíduo morre. Se sim, {
			i) destrói o indivíduo.
		}
		se não, sorteia se o indivíduo cresce. Se sim, {
			i) determina a CLASSE do indivíduo. {
				I) Se é "semente", muda CLASSE para "plântula"
				II) Se é "plântula", muda CLASSE para "adulto"
				III) Atualiza S, R, G e LAMBDA de acordo com a nova CLASSE
			}
		}
		se não,  sorteia se o indivíduo reproduz. Se sim, {
			i) sorteia o número N de sementes produzidas
			ii) repete N vezes {
				I) sorteia a posição (X,Y) onde a semente cairá de acordo com o KERNEL de dispersão
				II) CRIA semente nessa posição
			}
		}
	}
}
				
